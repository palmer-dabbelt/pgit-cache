all: bin/pgit

bin/pgit: src/pgit.bash
	mkdir -p $(dir $@)
	cat $^ | sed 's!@@TOP@@!$(abspath .)!' > $@
	chmod +x $@

.PHONY: clean
clean:
	rm -rf bin
