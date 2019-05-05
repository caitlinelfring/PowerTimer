clean_frames:
	rm -vf ./fastlane/screenshots/**/*_framed.png

clean_original_screenshots:
	find ./fastlane/screenshots -maxdepth 2 -not -name "*_framed.png"  | grep png | tr '\n' '\0' | xargs -0 rm

app_icons:
	./app_icons.sh images/Icon.png PowerTimer/Assets.xcassets/AppIcon.appiconset
