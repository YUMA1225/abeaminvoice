class CustomersController < ApplicationController
  def index
    @user = User.find(current_user.id)
  end

  def show
    @customer = Customer.find(params[:id])
  
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params)
    @customer.user_id = current_user.id
    @customer.save
    redirect_to customers_path
  end

  def edit
    @customer = Customer.find(params[:id])
  end

  def update
    @customer = Customer.find(params[:id])
    @customer.update(customer_params)
    redirect_to customer_path(@customer)
  end
  
  def destroy
    customer = Customer.find(params[:id])
    customer.destroy
    redirect_to customers_path
  end

  def create_invoice

  end


  private
  def customer_params
    params.require(:customer).permit(:name, :code, :manager)
  end

end
