require 'rails_helper'

RSpec.describe "layers/edit", type: :view do
  before(:each) do
    group = FactoryBot.create(:group)
    user = FactoryBot.create(:admin_user, :group_id => group.id)
    sign_in user
    @map = FactoryBot.create(:map, :group_id => group.id)
    @layer = assign(:layer, Layer.create!(
      :title => "MyString",
      :text => "MyString",
      :published => false,
      :map => @map
    ))
  end

  it "renders the edit layer form" do
    render

    assert_select "form[action=?][method=?]", map_layer_path(@layer, :map_id => @map.id), "post" do

      assert_select "input[name=?]", "layer[title]"

      assert_select "input[name=?]", "layer[text]"


    end
  end
end
