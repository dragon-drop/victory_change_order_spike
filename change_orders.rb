class ChangeOrderFlow
  class << self
    def create_change_order(change_order)
      contract = ContractGenerator.call(change_order)
      Notifier.call(:project_manager, :send, contract)

      if change_order.changes_contract_price?
        UpdatePrices.call(change_order.project)
        Notifier.call(:finance_manager, :adjust_agreements, change_order.project)
      end

      Notifier.call(:rpc, :order_materials, change_order) if change_order.changes_materials?
      Notifier.call(:pii, :update_work_order, change_order)  if change_order.changes_work_order?
    end
  end
end

ChangeOrder = Struct.new(:adjusted_cost, :project, :changes_contract_price?,:changes_materials?, :changes_work_order?)

class ContractGenerator
  def self.call(change_order); end
end


class UpdatePrices
  def self.call(project); end
end

class Notifier
  def self.call(user, action, resource)
    puts "#{user}: do #{action} to #{resource}"
  end
end

