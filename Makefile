.PHONY: clean test install all ci

test: install
	./scripts/test.sh

test-fail-fast: install
	./scripts/test.sh --fail-fast

install: deps/plenary.nvim deps/nvim-treesitter deps/toggleterm.nvim deps/nui.nvim deps/nvim-lspconfig

deps/plenary.nvim:
	mkdir -p deps
	git clone --depth 1 https://github.com/nvim-lua/plenary.nvim.git $@

deps/nvim-treesitter:
	mkdir -p deps
	git clone --depth 1 https://github.com/nvim-treesitter/nvim-treesitter.git $@

deps/nvim-lspconfig:
	mkdir -p deps
	git clone --depth 1 https://github.com/neovim/nvim-lspconfig $@

deps/nui.nvim:
	mkdir -p deps
	git clone --depth 1 https://github.com/MunifTanjim/nui.nvim $@

deps/toggleterm.nvim:
	mkdir -p deps
	git clone --depth 1 https://github.com/akinsho/toggleterm.nvim $@

clean:
	rm -rf deps

lint:
	luacheck ./lua/java_test_util/*.lua ./tests/unit/*.lua

format:
	stylua . --color always --check lua

ci: install
	make test && make lint && make format
