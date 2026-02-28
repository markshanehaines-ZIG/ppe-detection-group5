.PHONY: setup sync jupyter clean help

help:
	@echo "Available commands:"
	@echo "  make setup   - Set up the environment using uv"
	@echo "  make sync    - Sync dependencies using uv"
	@echo "  make jupyter - Run Jupyter Notebook using uv"
	@echo "  make clean   - Remove cache, build artifacts, and environments"

setup:
	@echo "Initializing uv environment..."
	uv sync

sync:
	@echo "Syncing dependencies..."
	uv sync

jupyter:
	@echo "Starting Jupyter Notebook..."
	uv run jupyter notebook notebooks/MAICEN_1125_M4_U4_Group_5_Assignment.ipynb

clean:
	@echo "Cleaning up..."
	rm -rf .venv
	rm -rf __pycache__
	rm -rf .pytest_cache
	rm -rf runs/
	find . -type f -name "*.pyc" -delete
	find . -type d -name ".ipynb_checkpoints" -exec rm -rf {} +
	@echo "Cleanup complete."
