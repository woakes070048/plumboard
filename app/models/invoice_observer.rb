class InvoiceObserver < ActiveRecord::Observer
  observe Invoice
  include PointManager

  # update points
  def after_create model
    PointManager::add_points model.seller, 'inv' if model.seller

    # send post
    send_post model
  end

  def after_update model
    # send post
    send_post(model) if model.unpaid?

    # toggle status
    if model.paid?
      mark_pixi(model) 

      # credit seller account
      if model.amount > 0

        # get txn amount & fee
        fee = model.transaction.convenience_fee

        # process payment
        result = model.bank_account.credit_account(model.amount - fee)

        # record payment
	if result
	  PixiPayment.add_transaction model, fee, result.uri, result.id 

          # send receipt upon approval
          UserMailer.delay.send_payment_receipt(model, result)
	end
      end
    end
  end

  private

  # notify buyer
  def send_post model
    Post.send_invoice model, model.listing  
  end

  # mark pixi as sold
  def mark_pixi model
    model.listing.mark_as_sold 
  end
end
