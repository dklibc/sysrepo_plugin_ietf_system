TARGET:=ietf_system.so

OBJ:= \
	main.o \

LDFLAGS+=-lsysrepo

SR_PLUGINS_DIR="$(DESTDIR)/usr/lib64/sysrepo/plugins"

.PHONY: clean all install uninstall clear_shm

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) -o $@ $^ -shared -fPIC $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^ -fPIC

clear_shm:
	rm /dev/shm/sr*

clean:
	rm -f $(TARGET) $(OBJ)

install: $(TARGET)
	echo "" >install_manifest.txt

	mkdir -p "$(SR_PLUGINS_DIR)"

	cp ietf_system.so "$(SR_PLUGINS_DIR)"
	echo "$(SR_PLUGINS_DIR)/ietf_system.so" >>install_manifest.txt

	killall sysrepo-plugind || true

	sysrepoctl -i ietf-system.yang -s ./ || true
	sysrepoctl -c ietf-system -p 644
	sysrepoctl -c ietf-system -s ./ -e ntp || true

	sysrepo-plugind

uninstall:
	killall sysrepo-plugind || true

	sysrepoctl -u ietf-system || true

	cat install_manifest.txt | xargs rm

	sysrepo-plugind
