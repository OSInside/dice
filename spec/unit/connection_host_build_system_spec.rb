require_relative "spec_helper"

describe ConnectionHostBuildSystem do
  before(:each) do
    expect_any_instance_of(Connection).to receive(:change_working_dir)
    @connection = ConnectionHostBuildSystem.new("spec/helper/recipe_good")
  end
end
