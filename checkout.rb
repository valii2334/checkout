# frozen_string_literal: true

require 'pry'

class CountItemsRule
  attr_accessor :items_count,
                :items_type,
                :price_to_be_applied

  def initialize(items_count:, items_type:, price_to_be_applied:)
    self.items_count         = items_count
    self.items_type          = items_type
    self.price_to_be_applied = price_to_be_applied
  end

  def can_be_applied?(items:)
    items.count >= items_count
  end

  def items_to_be_used(items:)
    items.select { |item| item.type == items_type && !item.used_in_a_promotion }
  end
end

class FinalPriceDiscount
end

class Item
  attr_accessor :type,
                :price,
                :used_in_a_promotion

  def initialize(type:, price:)
    self.type  = type
    self.price = price
    self.used_in_a_promotion = false
  end

  def mark_as_used
    self.used_in_a_promotion = true
  end
end

class Checkout
  attr_accessor :rules,
                :items,
                :price

  def initialize(rules:)
    self.rules = rules
    self.items = []
    self.price = 0
  end

  def scan(item)
    self.items = items << item
    apply_rule_for_same_type_item(item: item)
  end

  def total
    items.reject(&:used_in_a_promotion).each do |item_not_used_in_promotions|
      self.price += item_not_used_in_promotions.price
    end

    # if rule = final_price_rule
    #
    # end
  end

  def rule_applicable_for_item(item:)
    rules.find { |rule| rule.items_type == item.type }
  end

  def mark_items_as_used(items:)
    items.each(&:mark_as_used)
  end

  def final_price_rule
    self.rules.find{ |rule| rule.class == FinalPriceDiscount}
  end

  def apply_rule_for_same_type_item(item:)
    if rule = rule_applicable_for_item(item: item)
      same_type_items = rule.items_to_be_used(items: items)

      if rule.can_be_applied?(items: same_type_items)
        self.price += rule.price_to_be_applied
        mark_items_as_used(items: same_type_items.first(rule.items_count))
      end
    end
  end
end

rule_3_a = CountItemsRule.new(items_count: 3, items_type: 'A', price_to_be_applied: 75)
rule_2_b = CountItemsRule.new(items_count: 2, items_type: 'B', price_to_be_applied: 35)

checkout = Checkout.new(rules: [rule_3_a, rule_2_b])
checkout.scan(Item.new(type: 'A', price: 30))
checkout.scan(Item.new(type: 'A', price: 30))
checkout.scan(Item.new(type: 'A', price: 30))
checkout.scan(Item.new(type: 'A', price: 30))
checkout.scan(Item.new(type: 'b', price: 20))
checkout.total
