class DealsController < ApplicationController
  def new
    @customer = Customer.find(params[:customer_id])
    @deal = Deal.new
    
    
  end

  def create
    # if paem = ''
    #   'xlsx'
    #   'pdf'
    @deal = Deal.new(deal_params)
    @deal.customer_id = params[:customer_id]
    @deal.tax = 10
    @deal.save
    redirect_to customer_path(@deal.customer_id)
  end

  def edit
    @customer = Customer.find(params[:customer_id])
    @deal = Deal.find(params[:id])
  end

  def update
 
    @deal = Deal.find(params[:id])
    @deal.update(deal_params)
    redirect_to customer_path(params[:customer_id])
  end

  def show
  end

  def destroy
    
    deal = Deal.find(params[:id])
    deal.destroy
    redirect_to customer_path(params[:customer_id])
  end


  private
  def deal_params
    params.require(:deal).permit(:title, :price, :amount, :tax)
  end
end
