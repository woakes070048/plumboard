require "spec_helper"

describe Api::V1::RegistrationsController do
  describe 'registrations routes', base: true do
    it_should_behave_like 'an index route', false, 'index', 'api/v1/registrations'
    it_should_behave_like 'a get item route', false, 'new', 'api/v1/registrations'
    it_should_behave_like 'a get item route', false, 'show', 'api/v1/registrations'
    it_should_behave_like 'a get item route', false, 'edit', 'api/v1/registrations'
    it_should_behave_like 'a put route', false, 'update', 'api/v1/registrations'
    it_should_behave_like 'a post route', true, 'create', 'api/v1/registrations'
    it_should_behave_like 'a delete route', false, 'destroy', 'api/v1/registrations'
  end
end
