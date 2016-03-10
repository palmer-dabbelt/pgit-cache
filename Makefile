all: bin/pgit \
     enter.bash

bin/pgit: src/pgit.bash
	mkdir -p $(dir $@)
	cat $^ | sed 's!@@TOP@@!$(abspath .)!' > $@
	chmod +x $@

enter.bash:
	echo 'export PATH="$(abspath bin):$$PATH"' > $@

.PHONY: clean
clean:
	rm -rf bin
