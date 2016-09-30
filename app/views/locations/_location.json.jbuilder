json.id location.to_param
json.loctype location.loctype
json.title location.title
json.description location.description
json.team_name location.team_name
json.team_id location.team.try(:to_param)
json.website location.website.try(:strip) || ''
json.phone location.phone || ''
json.email location.email || ''
json.facebook location.facebook || ''
json.instagram location.instagram || ''
json.twitter location.twitter || ''
json.distance location.distance || ''
json.city location.city
json.country location.country
json.state location.state || ''
json.postal_code location.postal_code
json.street location.street || ''
json.address location.address
json.timezone location.timezone
json.lat location.lat
json.lng location.lng
json.image location.image
json.flag_has_black_belt location.flag_has_black_belt || false
json.flag_closed location.flag_closed || false