require 'mongoid-history'

class Team
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  track_history   :on => :all,
                  :modifier_field => :modifier, # adds "belongs_to :modifier" to track who made the change, default is :modifier
                  :modifier_field_inverse_of => :nil, # adds an ":inverse_of" option to the "belongs_to :modifier" relation, default is not set
                  :version_field => :version,   # adds "field :version, :type => Integer" to track current version, default is :version
                  :track_create   =>  true,    # track document creation, default is false
                  :track_update   =>  true,     # track document updates, default is true
                  :track_destroy  =>  true     # track document destruction, default is false
  field :name, type: String
  field :description, type: String
  field :image_tiny, type: String
  field :image, type: String
  field :image_large, type: String
  field :primary_color_index, type: String
  field :locked, type: Boolean

  has_many :locations
  has_many :users
  belongs_to :parent_team, class_name: 'Team', inverse_of: :child_teams
  has_many :child_teams, class_name: 'Team', inverse_of: :parent_team

  validates :name, presence: true

  def editable_by? user
    return !self.locked? || user.super_user?
  end

  def as_json(args)
    super(args.merge(except: [:_id, :parent_team_id, :modifier_id])).merge({
      :id => self.id.to_s,
      :modifier_id => self.modifier_id.to_s,
      :parent_team_id => self.parent_team_id.try(:to_s)
    })
  end

  def to_param
    [id, name.parameterize].join('-')
  end
end
