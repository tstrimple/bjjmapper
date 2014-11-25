require 'wikipedia'

class User
  include Mongoid::Document
  include Geocoder::Model::Mongoid
  include Mongoid::Timestamps

  include Mongoid::History::Trackable

  track_history   :on => :all,
                  :modifier_field => :modifier, # adds "belongs_to :modifier" to track who made the change, default is :modifier
                  :modifier_field_inverse_of => :nil, # adds an ":inverse_of" option to the "belongs_to :modifier" relation, default is not set
                  :version_field => :version,   # adds "field :version, :type => Integer" to track current version, default is :version
                  :track_create   =>  true,    # track document creation, default is false
                  :track_update   =>  true,     # track document updates, default is true
                  :track_destroy  =>  true     # track document destruction, default is false

  field :role, type: String
  field :provider, type: String
  field :uid, type: String
  field :name, type: String
  field :email, type: String
  field :image, type: String
  field :ip_address, type: String
  field :coordinates, type: Array
  field :last_seen_at, type: Integer
  field :description, type: String
  field :summary, type: String
  field :description_src, type: String

  field :oauth_token, type: String
  field :oauth_expires_at, type: Integer

  field :belt_rank, type: String
  field :stripe_rank, type: Integer
  field :birth_day, type: Integer
  field :birth_month, type: Integer
  field :birth_year, type: Integer
  field :birth_place, type: String
  field :internal, type: Boolean

  geocoded_by :ip_address
  after_validation :safe_geocode

  belongs_to :lineal_parent, class_name: 'User', inverse_of: :lineal_children
  has_many :lineal_children, class_name: 'User', inverse_of: :lineal_parent
  belongs_to :team
  has_and_belongs_to_many :locations

  before_create do
    if :instructor == role.try(:to_sym)
      page = Wikipedia.find(name)
      if page.content.present?
        self.image = page.image_urls.last
        self.description_src = :wikipedia
        self.description = page.content
      end
    end
  end

  scope :jitsukas, -> { where(:belt_rank.ne => nil) }

  def jitsuka?
    self.belt_rank.present?
  end

  def self.create_anonymous(ip_address)
    User.create(provider: 'anonymous', role: 'anonymous', ip_address: ip_address, name: "Anonymous #{ip_address}", last_seen_at: Time.now)
  end

  def self.from_omniauth(auth, ip_address)
    User.where(provider: auth['provider'], uid: auth['uid'])
        .first_or_initialize(
          name: auth.try(:[], 'info').try(:[], 'name'),
          email: auth.try(:[], 'info').try(:[], 'email'),
          ip_address: ip_address,
          oauth_token: auth.try(:credentials).try(:token),
          oauth_expires_at: Time.at(auth.try(:credentials).try(:expires_at) || 0),
          last_seen_at: Time.now
        )
  end

  def anonymous?
    self.role.try(:to_s).try(:eql?, 'anonymous')
  end

  def full_lineage
    # TODO: Is this expensive? Is caching enough?
    lineage = []
    u = self.lineal_parent
    while u.present?
      lineage << u
      u = u.lineal_parent
    end
    lineage
  end

  def birthdate
    return nil unless birth_year.present? && birth_month.present? && birth_day.present?
    Date.new(birth_year, birth_month, birth_day)
  end

  def age_in_years
    d = Time.now
    a = d.year - birth_year
    a = a - 1 if (
         birth_month >  d.month or 
        (birth_month >= d.month and birth_day > d.day)
    )
    a
  end

  def as_json(args)
    super(args.merge(except: [:ip_address, :coordinates, :uid, :provider, :email, :_id])).merge({
      :id => self.id.to_s
    })
  end

  private

  def safe_geocode
    begin
      geocode
    rescue StandardError => e
      Rails.logger.error(e)
    end
  end
end

