Hvor::Engine.routes.draw do
  get "lookup", to: "lookups#show"
  get "lookup/me", to: "lookups#me"
end
