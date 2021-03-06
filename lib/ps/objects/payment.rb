module PS
  class Payment < Object
    attr_accessor :ref_payment_id,:customer_id,:customer_account_id,:amount,:status,:payment_date,:invoice_id,:recurring_schedule_id,:is_debit,:payment_type,:payment_sub_type,:provider_auth_code,:trace_number,:estimate_settled_date,:actual_settled_date,:can_void_until,:invoice_number,:purchase_order_number,:order_id,:description 

    def cancel
      request("cancelpayment", { :paymentId => self.ps_reference_id }, &update_by_find)
    end

    def reverse
      request("reversepayment", { :paymentId => self.ps_reference_id }, &update_by_find)
    end

    class << self 
      def list(customer_id, criteria=nil)
        request("listpayments", { :customerId => customer_id, :criteria => criteria }, &instantiate_object)
      end
      
      def reverse_by_id(payment_id)
        request("reversepayment", { :paymentId => payment_id })
        true
      end

      def cancel_by_id(payment_id)
        request("cancelpayment", { :paymentId =>  payment_id })
        true
      end

      def make(customer_id, amount, account_id=nil, cid="", order_details=nil)
        request("makepayment", 
          {
            :customerId => customer_id,
            :customerAccountId => account_id,
            :amount => amount,
            :cid => cid,
            :detail => order_details 
          }, &instantiate_object)
      end
    end

    private
      def update_by_find
        Proc.new do
          i = 0
          loop do
            payments = self.class
            .list(self.customer_id, { :page => i, :items_per_page => 200 })
            case payments
            when []
              break
            when Array
              updated = false
              payments.each do |payment|
                if payment.ps_reference_id == self.ps_reference_id then
                  set_attributes(payment.attributes) 
                  updated = true
                  break
                end
              end
              break if updated
            when PS::Payment
              if payments.ps_reference_id == self.ps_reference_id then
                set_attributes(payments.attributes) 
              end
              # break here because if only one payment is returned, then it's
              # only one that exists or it is the last one...
              break
            end
            i += 1
          end
        end
      end
  end
end
