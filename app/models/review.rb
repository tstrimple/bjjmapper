class Review
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user, index: true
  belongs_to :location, index: true

  field :body
  field :rating

  validates :user, presence: true
  validates :location, presence: true
  validates :body, presence: true
  validates :rating, presence: true, inclusion: 1..5

  def as_json(options = {})
    {
      :user_name => self.user.name,
      :user_id => self.user.id.to_s,
      :body => self.body,
      :rating => self.rating.try(:to_i) || 0,
      :created_at => self.created_at.strftime("%B %e, %Y")
    }
  end
end