class Guide::BaseController < Guide.configuration.controller_class_to_inherit.constantize
  helper Rails.application.routes.url_helpers
  layout 'guide/application'

  private

  around_filter :set_locale
  def set_locale
    I18n.with_locale(diplomat.negotiate_locale) { yield }
  end

  around_filter :handle_known_errors
  def handle_known_errors
    begin
      yield
    rescue Guide::Errors::Base => error
      raise error if Rails.env.development?

      case error
      when Guide::Errors::InvalidNode, Guide::Errors::PermissionDenied
        render :text => 'Nothing to see here.', :status => '404'
      else
        render :text => "Something's gone wrong. Sorry about that.", :status => '500'
      end
    end
  end

  def active_node
    @node ||= monkey.fetch_node(node_path)
  end

  def bouncer
    @bouncer ||= Guide::Bouncer.new(authorisation_system)
  end

  def authorisation_system
    # Override this method if you need to pass arguments into whatever
    # implementation of Guide::AuthorisationSystem works for your application
    @authorisation_system ||= Guide::AuthorisationSystem.new
  end

  def content
    @content ||= Guide::Content.new
  end

  def diplomat
    @diplomat ||= Guide::Diplomat.new(session, params, I18n.default_locale)
  end

  def monkey
    Guide::Monkey.new(content, bouncer)
  end

  def nobilizer
    Guide::Nobilizer.new
  end

  def active_node_visibility
    Guide::Scout.new(content).visibility_along_path(node_path)
  end

  def node_path
    params[:node_path] || ""
  end
end
