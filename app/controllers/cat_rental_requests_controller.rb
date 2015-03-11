class CatRentalRequestsController < ApplicationController
  def approve
    @cr = CatRentalRequest.find(params[:id])
    @cr.approve!
    redirect_to Cat.find(@cr.cat_id)
  end

  def deny
    @cr = CatRentalRequest.find(params[:id])
    @cr.deny!
    redirect_to Cat.find(@cr.cat_id)
  end

  def new
    @cr ||= CatRentalRequest.new
    render :new
  end

  def create
    @cr = CatRentalRequest.new(cat_rental_params)
    if @cr.save
      redirect_to @cr
    else
      self.new
    end
  end

  def edit
    @cr = CatRentalRequest.find(params[:id])
  end

  def update
    @cr = Cat.find(params[:id])
    if @cr.update(cat_rental_params)
      redirect_to @cr
    else
      render :edit
    end
  end

  def delete
    @cr = Cat.find(params[:id])
    @cr.destroy
    redirect_to :index
  end

  private

  def cat_rental_params
    params.require(:cat_rental_request).permit(:cat_id, :start_date, :end_date, :status)
  end
end
