require_dependency 'hashie'

class Rating < ActiveRecord::Base
  GOOD = 1.freeze
  NORMAL = 0.freeze
  BAD = -1.freeze

  belongs_to :seller, class_name: 'User', counter_cache: true
  belongs_to :bidder, class_name: 'User'

  validates :seller_id, :bidder_id, :value, :comment, presence: true

  def self.aggregate(seller_id)
    aggregates = {}
    ['GOOD', 'NORMAL', 'BAD'].each do |status|
      # 少しDRYに
      # %w(week month year).each do |date_range|
      #   aggregates["#{status.downcase}_count_of_#{date_range}".to_sym] = Rating.where(seller_id: seller_id,
      #     value: "Rating::#{status}".constantize, created_at: Time.current.send("at_beginning_of_#{date_range}")..Time.now).count
      aggregates["#{status.downcase}_count_of_week".to_sym] = Rating.where(seller_id: seller_id,
        value: "Rating::#{status}".constantize, created_at: Time.now.at_beginning_of_week..Time.now).count
      aggregates["#{status.downcase}_count_of_month".to_sym] = Rating.where(seller_id: seller_id,
        value: "Rating::#{status}".constantize, created_at: Time.now.at_beginning_of_month..Time.now).count
      aggregates["#{status.downcase}_count_of_year".to_sym] = Rating.where(seller_id: seller_id,
        value: "Rating::#{status}".constantize, created_at: Time.now.at_beginning_of_year..Time.now).count
      aggregates["#{status.downcase}_count_in_hundred".to_sym] =
        Rating.where(seller_id: seller_id).order(created_at: :desc).limit(100).map do |rate|
          # そのRaitingの数(size)が知りたいのなら map でなくて select かも。
          rate.value == "Rating::#{status}".constantize
        end.size
      aggregates["#{status.downcase}_count_in_thousand".to_sym] =
        Rating.where(seller_id: seller_id).order(created_at: :desc).limit(1000).map do |rate|
          rate.value == "Rating::#{status}".constantize
        end.size
    end

    ::Hashie::Mash.new(aggregates)
  end
end
