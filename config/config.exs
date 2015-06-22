# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :param_session,
  store: :cookie,  
  key: "session",
  encryption_salt: "fkljsdfsdif-09sdf-9834j993920092090kjj",
  signing_salt: "skljdfls9980982049834fsdfsdf900d",
  key_length: 64
