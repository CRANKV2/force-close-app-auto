#!/system/bin/sh

# Include the configuration file
source allowed_apps.conf

# Create an array from the configuration file
declare -a allowed_apps
for line in $(cat allowed_apps.conf); do
  allowed_apps+=($line)
done


while true; do
  # Get the package name of the foreground app
  package_name=$(su -c dumpsys activity activities | grep "mFocusedActivity" | cut -d " " -f 5 | cut -d "/" -f 1)

  # Check if the current app is allowed to run in the background
  allowed=false
  for app in "${allowed_apps[@]}"; do
    if [ "$app" = "$package_name" ]; then
      allowed=true
      break
    fi
  done

  # If the current app is not allowed to run in the background, force stop all other apps
  if ! $allowed; then
    su -c "am force-stop --user 0 '*'"
  fi

  # Sleep for 1 second before checking again
  sleep 1
done
