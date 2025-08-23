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
│   ├── enum/                     #Enum modules
│   │   └── brand_tier.rb   
│   │   └── card_brand.rb  
│   │   └── card_type.rb  
│   │   └── customer_tier.rb  
│   │   └── payment_method.rb            
│   ├── exceptions/               # Custom exception classes
│   │   ├── discount_calculation_exception.rb
│   │   └── discount_validation_exception.rb
│   ├── discount_service.rb       # Main service class
│   └── ecom_discount_services.rb # Main entry point
├── spec/                         # Test files
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
  tier: CustomerTier::GOLD,
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

### Brand Based Discounts

- **Puma**: 40% discount
- **Nike**: 25% discount
- **Adidas**: 15% discount

### Category Discounts

- **Electronics**: 15% discount
- **Clothing**: 10% discount
- **Books**: 8% discount
- **Home**: 5% discount

### Available Coupon Codes

- `SUPER69`: 69 Instant discount
- `WELCOME10`: 10 Instant discount  

### Bank Discounts

- **ICICI**: 5% discount
- **HDFC**: 4% discount
- **AXIS**: 3% discount

### DiscountService

#### `calculate_cart_discounts(cart_items:, customer:, payment_info: nil, coupon_code: nil)`

Calculates the total discount for a shopping cart.

**Parameters:**
- `cart_items`: Array of CartItem objects
- `customer`: CustomerProfile object
- `payment_info`: PaymentInfo object (optional)
- `coupon_code`: String coupon code (optional)

**Returns:** DiscountedPrice object


### Entity Classes

#### CustomerProfile
- `id`: String
- `tier`: ENUM (gold, silver, bronze)
- `email`: String
- `phone`: String (optional)
- `address`: String (optional)

#### Product
- `id`: Integer
- `brand`: String
- `brandtier`: ENUM (premium, regular, budget)
- `category`: String
- `base_price`: BigDecimal
- `current_price`: BigDecimal (optional)

#### CartItem
- `product`: Product object
- `quantity`: Integer
- `size`: String (optional)

#### PaymentInfo
- `method`: ENUM (UPI, CARD, BANK_TRANSFER)
- `bank_name`: String (optional)
- `card_type`: ENUM (CREDIT_CARD, DEBIT_CARD) (optional)
- `card_brand`: ENUM (VISA, MASTER, AMEX) (optional)

#### DiscountedPrice
- `original_price`: BigDecimal
- `final_price`: BigDecimal
- `applied_discounts`: Hash
- `message`: String


## Integration tests simulate the full discount calculation process using sample/fake data. 
## These tests validate that multiple discount strategies work together correctly.

```bash
bundle exec rspec spec/integration/discount_service_integration_spec.rb
```

## Unit tests verify the behavior of individual components or discount strategies in isolation.
## Example: Testing the Bank Discount strategy

```bash
bundle exec rspec spec/strategies/bank_discount_spec.rb
```

## Error Handling

The service includes custom exception classes:

- `DiscountCalculationException`: Raised when discount calculation fails
- `DiscountValidationException`: Raised when discount validation fails

Class Diagram


Initial Instructions to Cursor