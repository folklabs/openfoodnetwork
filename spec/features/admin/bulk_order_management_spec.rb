require 'spec_helper'

feature %q{
  As an Administrator
  I want to be able to manage orders in bulk
} , js: true do
  include AuthenticationWorkflow
  include WebHelper

  before :all do
    @default_wait_time = Capybara.default_wait_time
    Capybara.default_wait_time = 5
  end

  after :all do
    Capybara.default_wait_time = @default_wait_time
  end

  context "listing orders" do
    before :each do
      login_to_admin_section
    end

    it "displays a Bulk Management Tab under the Orders item" do
      visit '/admin/orders'

      page.should have_link "Bulk Order Management"
      click_link "Bulk Order Management"
      page.should have_selector "h1.page-title", text: "Bulk Order Management"
    end

    context "displaying individual columns" do
      let!(:o1) { FactoryGirl.create(:order, state: 'complete', completed_at: Time.now ) }
      let!(:o2) { FactoryGirl.create(:order, state: 'complete', completed_at: Time.now ) }
      let!(:li1) { FactoryGirl.create(:line_item, order: o1 ) }
      let!(:li2) { FactoryGirl.create(:line_item, order: o2 ) }

      before :each do
        visit '/admin/orders/bulk_management'
      end

      it "displays a list of line items" do
        page.should have_selector "th.id", text: "ID", :visible => true
        page.should have_selector "td.id", text: li1.id.to_s, :visible => true
        page.should have_selector "td.id", text: li2.id.to_s, :visible => true
      end

      it "displays a column for user email" do
        page.should have_selector "th.email", text: "EMAIL", :visible => true
        page.should have_selector "td.email", text: o1.email, :visible => true
        page.should have_selector "td.email", text: o2.email, :visible => true
      end

      it "displays a column for order date" do
        page.should have_selector "th,date", text: "ORDER DATE", :visible => true
        page.should have_selector "td.date", text: o1.completed_at.strftime("%F %T"), :visible => true
        page.should have_selector "td.date", text: o2.completed_at.strftime("%F %T"), :visible => true
      end

      it "displays a column for producer" do
        page.should have_selector "th.producer", text: "PRODUCER", :visible => true
        page.should have_selector "td.producer", text: li1.product.supplier.name, :visible => true
        page.should have_selector "td.producer", text: li2.product.supplier.name, :visible => true
      end

      it "displays a column for variant description" do
        page.should have_selector "th.variant", text: "PRODUCT (UNIT): VAR", :visible => true
        page.should have_selector "td.variant", text: li1.product.name, :visible => true
        page.should have_selector "td.variant", text: li2.product.name, :visible => true
      end

      it "displays a column for quantity" do
        page.should have_selector "th.quantity", text: "QUANTITY", :visible => true
        page.should have_selector "td.quantity", text: li1.quantity.to_s, :visible => true
        page.should have_selector "td.quantity", text: li2.quantity.to_s, :visible => true
      end

      it "displays a column for max quantity" do
        page.should have_selector "th.max", text: "MAX", :visible => true
        page.should have_selector "td.max", text: li1.max_quantity.to_s, :visible => true
        page.should have_selector "td.max", text: li2.max_quantity.to_s, :visible => true
      end
    end

    context "using page page controls" do
      context "using drop down seletors" do
        let!(:s1) { FactoryGirl.create(:supplier_enterprise) }
        let!(:s2) { FactoryGirl.create(:supplier_enterprise) }
        let!(:d1) { FactoryGirl.create(:distributor_enterprise) }
        let!(:d2) { FactoryGirl.create(:distributor_enterprise) }
        let!(:p1) { FactoryGirl.create(:product, supplier: s1 ) }
        let!(:p2) { FactoryGirl.create(:product, supplier: s2 ) }
        let!(:o1) { FactoryGirl.create(:order, state: 'complete', completed_at: Time.now, distributor: d1 ) }
        let!(:o2) { FactoryGirl.create(:order, state: 'complete', completed_at: Time.now, distributor: d2 ) }
        let!(:li1) { FactoryGirl.create(:line_item, order: o1, product: p1 ) }
        let!(:li2) { FactoryGirl.create(:line_item, order: o2, product: p2 ) }

        before :each do
          visit '/admin/orders/bulk_management'
        end

        it "displays a select box for producers, which filters line items by the selected supplier" do
          page.should have_select "supplier_filter", with_options: [s1.name,s2.name]
          page.should have_selector "td.id", text: li1.id.to_s, visible: true
          page.should have_selector "td.id", text: li2.id.to_s, visible: true
          select s1.name, from: "supplier_filter"
          page.should have_selector "td.id", text: li1.id.to_s, visible: true
          page.should_not have_selector "td.id", text: li2.id.to_s, visible: true
        end

        it "displays a select box for distributors, which filters line items by the selected distributor" do
          page.should have_select "distributor_filter", with_options: [d1.name,d2.name]
          page.should have_selector "td.id", text: li1.id.to_s, visible: true
          page.should have_selector "td.id", text: li2.id.to_s, visible: true
          select d1.name, from: "distributor_filter"
          page.should have_selector "td.id", text: li1.id.to_s, visible: true
          page.should_not have_selector "td.id", text: li2.id.to_s, visible: true
        end
      end
    end
  end
end