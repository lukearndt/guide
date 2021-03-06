require 'rails_helper'

RSpec.describe Guide::NodesController, :type => :controller do
  routes { Guide::Engine.routes }

  describe '#show' do
    let(:show) { get :show, :node_path => node_path }
    let(:node_path) { 'structures/friendly/example' }

    context "given the node_path points to a valid node" do
      context "the user is allowed to see the active node" do
        include_context description do
          before { show }

          it "renders the show template" do
            aggregate_failures do
              expect(response).to have_http_status(:ok)
              expect(response).to render_template(:show)
            end
          end

          it "exposes a NavigationView to the template as @navigation_view" do
            expect(assigns(:navigation_view)).
              to be_a Guide::NavigationView
          end

          it "exposes a LayoutView to the template as @layout_view" do
            expect(assigns(:layout_view)).
              to be_a Guide::LayoutView
          end

          it "exposes a NodeView to the template as @node_view" do
            expect(assigns(:node_view)).
              to be_a Guide::NodeView
          end
        end
      end

      context "given the node_path doesn't point to a valid node" do
        let(:show) { get :show, :node_path => 'totally/bogus/node' }

        context "we are not in a development environment" do
          include_context description do
            before { show }

            it "renders a 404 not found response" do
              expect(response).to have_http_status(:not_found)
            end

            it "does not render the show template" do
              expect(response).not_to render_template(:show)
            end
          end
        end

        context "we are in a development environment" do
          include_context description do
            it "raises an InvalidNode error so that we can see what went wrong" do
              expect { show }.
                to raise_error(Guide::Errors::InvalidNode)
            end
          end
        end
      end
    end

    context "the user is not allowed to see the active node" do
      include_context description do
        context "we are not in a development environment" do
          include_context description do
            before { show }

            it "renders a 404 not found response" do
              expect(response).to have_http_status(:not_found)
            end

            it "does not render the show template" do
              expect(response).not_to render_template(:show)
            end
          end
        end

        context "we are in a development environment" do
          include_context description do
            it "raises an Guide::PermissionDenied error so that we can see what went wrong" do
              expect { show }.
                to raise_error(Guide::Errors::PermissionDenied)
            end
          end
        end
      end
    end
  end
end
