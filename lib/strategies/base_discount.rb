class BaseDiscount
  # This method should be overridden by subclasses to apply specific discounts.
  def apply_discount(cart_items:, current_price:, **kwargs)
    raise NotImplementedError, "Subclasses must implement the apply method"
  end
end