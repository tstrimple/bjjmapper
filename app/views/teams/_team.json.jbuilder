json.id team.id.try(:to_s)
json.param team.to_param.to_s
json.image team.image
json.image_tiny team.image_tiny
json.image team.image
json.image_large team.image_large
json.modifier_id team.modifier_id.try(:to_s)
json.parent_team_id team.parent_team_id.try(:to_s)
json.created_at team.created_at
json.updated_at team.updated_at
json.locked team.locked
json.description team.description
json.name team.name
