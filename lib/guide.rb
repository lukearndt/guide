require "guide/engine"

module Guide
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :company_name, :project_name, :controller_class_to_inherit, :default_javascripts, :default_stylesheets

    def initialize
      @company_name = 'Your awesome company'
      @project_name = 'The Project'
      @controller_class_to_inherit = 'ActionContoller::Base'
      @default_javascripts = []
      @default_stylesheets = []
    end
  end
end
