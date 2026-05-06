{ config, currentUsername, ... }:
{
  # Use the username passed from flake
  # This makes the configuration portable across different systems/usernames
  home.username = currentUsername;
  home.homeDirectory = "/home/${currentUsername}";
}