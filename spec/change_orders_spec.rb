require_relative "../change_orders"

RSpec.describe ChangeOrderFlow do 
  describe "creating a new change order" do
    let(:change_order) {  ChangeOrder.new(project:) }
    let(:project) {  double }
    let(:contract) { double }

    before do 
        allow(ContractGenerator).to receive(:call) { contract }
        allow(UpdatePrices).to receive(:call)
        allow(Notifier).to receive(:call)
    end

    it "generates a change order contract" do 
      described_class.create_change_order(change_order)
      expect(ContractGenerator).to have_received(:call).with(change_order)
    end
    
     it "notifies the project manager to send the generated contract" do 
      described_class.create_change_order(change_order)
       expect(Notifier).to have_received(:call).with(:project_manager, :send, contract)
     end

    context "when the contract price has changed" do 
      before do
        allow(change_order).to receive(:changes_contract_price?) { true }
      end

      it "updates the project's prices" do 
        described_class.create_change_order(change_order)
        expect(UpdatePrices).to have_received(:call).with(project)
      end

     it "notifies the finance manager to adjust the project agreements" do 
        described_class.create_change_order(change_order)
       expect(Notifier).to have_received(:call).with(:finance_manager, :adjust_agreements, project)
     end
    end

    context "when the price has not changed" do 
      before do
        allow(change_order).to receive(:changes_contract_price?) { false }
      end

      it "does not update the project's prices" do 
        described_class.create_change_order(change_order)
        expect(UpdatePrices).not_to have_received(:call)
      end
     it "does not notify the finance manager" do
        described_class.create_change_order(change_order)
       expect(Notifier).not_to have_received(:call).with(:finance_manager, any_args)
     end

    end

    context "when materials have changed" do
      let(:change_order) { ChangeOrder.new(project:, changes_materials?: true) }
      it "notifies the RPC to order / cancel materials" do 
        described_class.create_change_order(change_order)
       expect(Notifier).to have_received(:call).with(:rpc, :order_materials, change_order)
      end
    end

    context "when materials have not changed" do
      let(:change_order) { ChangeOrder.new(project:, changes_materials?: false) }
      it "does not notify the RPC" do 
        described_class.create_change_order(change_order)
       expect(Notifier).not_to have_received(:call).with(:rpc, :order_materials, any_args)
      end
    end

    context "when work orders have changed" do
      let(:change_order) { ChangeOrder.new(project:, changes_work_order?: true) }
      it "notifies the PII to update the work order" do 
        described_class.create_change_order(change_order)
       expect(Notifier).to have_received(:call).with(:pii, :update_work_order, change_order)
      end
    end

    context "when work orders have not changed" do
      let(:change_order) { ChangeOrder.new(project:, changes_work_order?: false) }
      it "does not notify the PII" do 
        described_class.create_change_order(change_order)
       expect(Notifier).not_to have_received(:call).with(:pii, :update_work_order, any_args)
      end
    end
    
  end
end
