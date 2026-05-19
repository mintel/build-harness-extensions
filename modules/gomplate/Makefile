.PHONY: gomplate/render

## Render gomplate templates if .gomplate.yaml exists; no-op otherwise
gomplate/render:
	@if [ -f .gomplate.yaml ]; then \
		gomplate --config .gomplate.yaml; \
	fi
