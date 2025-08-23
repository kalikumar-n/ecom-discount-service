# Ecommerce Discount Services

A Ruby backend service for calculating discounts in ecommerce applications. This service provides a comprehensive discount calculation system that applies multiple types of discounts based on brand tiers, product categories, coupon codes, and payment methods.

## Features

- **Brand Tier Discounts**: Automatic discounts based on product brand tiers (Premium, Regular, Budget)
- **Category Discounts**: Product category-specific discounts
- **Coupon Code Validation**: Support for percentage and flat amount coupon codes
- **Bank-Specific Discounts**: Payment method and bank-specific discounts
- **Comprehensive Error Handling**: Custom exception classes for discount calculation and validation errors
- **Flexible Discount Stacking**: Multiple discounts can be applied in sequence

## Project Structure

```
ecom-discount-services/
├── lib/
│   ├── entity/                    # Entity classes
│   │   ├── customer_profile.rb    # Customer profile with tier information
│   │   ├── product.rb            # Product with brand tier and category
│   │   ├── cart_item.rb          # Shopping cart item
│   │   ├── payment_info.rb       # Payment method information
│   │   └── discounted_price.rb   # Discount calculation result
│   ├── enum/
│   │   └── brand_tier.rb         # Brand tier enumeration
│   ├── exceptions/               # Custom exception classes
│   │   ├── discount_calculation_exception.rb
│   │   └── discount_validation_exception.rb
│   ├── discount_service.rb       # Main service class
│   └── ecom_discount_services.rb # Main entry point
├── spec/                         # Test files
├── example.rb                    # Usage example
├── Gemfile                       # Ruby dependencies
└── README.md                     # This file
```

## Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   ```

## Usage

### Basic Usage

```ruby
require_relative 'lib/ecom_discount_services'

# Create products
product = Product.new(
  id: 1,
  brand: 'Apple',
  brandtier: BrandTier::PREMIUM,
  category: 'electronics',
  base_price: 999.99
)

# Create cart items
cart_items = [CartItem.new(product: product, quantity: 1)]

# Create customer
customer = CustomerProfile.new(
  id: 'CUST001',
  tier: 'premium',
  email: 'customer@example.com'
)

# Calculate discounts
result = DiscountService.calculate_cart_discounts(
  cart_items: cart_items,
  customer: customer,
  coupon_code: 'SAVE20'
)

puts "Final Price: $#{result.final_price}"
puts "Total Discount: $#{result.total_discount}"
```

### Available Coupon Codes

- `SAVE10`: 10% discount
- `SAVE20`: 20% discount  
- `SAVE30`: 30% discount
- `FLAT50`: $50 flat discount

### Brand Tier Discounts

- **Premium**: 15% discount
- **Regular**: 10% discount
- **Budget**: 5% discount

### Category Discounts

- **Electronics**: 12% discount
- **Clothing**: 8% discount
- **Books**: 15% discount
- **Home**: 10% discount

### Bank Discounts

- **Chase**: 5% discount
- **Bank of America**: 3% discount
- **Wells Fargo**: 4% discount

## API Reference

### DiscountService

#### `calculate_cart_discounts(cart_items:, customer:, payment_info: nil, coupon_code: nil)`

Calculates the total discount for a shopping cart.

**Parameters:**
- `cart_items`: Array of CartItem objects
- `customer`: CustomerProfile object
- `payment_info`: PaymentInfo object (optional)
- `coupon_code`: String coupon code (optional)

**Returns:** DiscountedPrice object

#### `validate_discount_code(code:, cart_items:, customer:)`

Validates if a coupon code is valid.

**Parameters:**
- `code`: String coupon code
- `cart_items`: Array of CartItem objects
- `customer`: CustomerProfile object

**Returns:** Boolean

### Entity Classes

#### CustomerProfile
- `id`: String
- `tier`: String (premium, regular, budget)
- `email`: String
- `phone`: String (optional)
- `address`: String (optional)

#### Product
- `id`: Integer
- `brand`: String
- `brandtier`: BrandTier enum value
- `category`: String
- `base_price`: BigDecimal
- `current_price`: BigDecimal

#### CartItem
- `product`: Product object
- `quantity`: Integer
- `size`: String (optional)

#### PaymentInfo
- `method`: String
- `bank_name`: String (optional)
- `card_type`: String (optional)

#### DiscountedPrice
- `original_price`: BigDecimal
- `final_price`: BigDecimal
- `applied_discounts`: Hash
- `message`: String

## Running the Example

```bash
ruby example.rb
```

This will demonstrate the discount calculation with various scenarios.

## Testing

```bash
bundle exec rspec
```

## Error Handling

The service includes custom exception classes:

- `DiscountCalculationException`: Raised when discount calculation fails
- `DiscountValidationException`: Raised when discount validation fails

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License. 