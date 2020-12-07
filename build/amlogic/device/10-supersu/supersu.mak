#
# Установка SuperSU в системном режиме (непосредственно в /system).
#
#DISABLED = yes

#SUPERSU_ZIP = ingredients/UPDATE-SuperSU-v2.82-20170528234214.zip
#$(call ASSERT.FILE,$(SUPERSU_ZIP))

HELP = Install SuperSU
#DEPS += $(DIR)apk-patches/*

define DESC
Установлена последняя версия SuperSU.
В этой версии отключена проверка на обновление, иначе можно легко привести
систему в неработоспособное состояние.

В данной прошивке не рекомендуется использовать другие версии SuperSU,
SuperUser, Magisk и подобных приложений. Установленной версии SuperSU
хватит для всех потребностей в контексте применения Android TV устройства.
endef

# Команды для установки SuperSU.
#
# В прошивке Beelink уже присутствует демон supersu и команда su.
# Нам нужно лишь обновить их до последней версии и хакнуть слегонца
# SuperSU.apk так, чтобы он не проверял "правильность установки", иначе
# он предлагает "обновить su" и это заканчивается зависанием при загрузке.
define INSTALL
	#mkdir -p $(SYSTEM)/system/app/SuperSU
	#unzip -qojp $(SUPERSU_ZIP) common/Superuser.apk > $(SYSTEM)/system/app/SuperSU/SuperSU.apk
	# Пропатчим SuperSU
	#$(call APPLY.PATCH.APK,$(SYSTEM)/system/app/SuperSU/SuperSU.apk,$(DIR)apk-patches)
	#unzip -qoj $(SUPERSU_ZIP) armv7/su -d $(SYSTEM)/system/xbin
	cp $(DIR)sudaemon.sh $(SYSTEM)/system/bin
	cp $(DIR)daemonsu $(SYSTEM)/system/xbin 
	cp $(DIR)root.rc $(SYSTEM)/system/etc/init
	tools/img-link -f su $(SYSTEM)/system/xbin/daemonsu
	tools/img-perm -f $(DIR)supersu.perm -b $(SYSTEM)
	sed -e 's/^.\{,7\}//' $(BCT.DIR)system/system_contexts > $(S.SELINUX)/system_contexts
	rm $(BCT.DIR)system/system_contexts
endef

# Рецепт взят из файла META-INF/com/google/android/update-binary
# для установки SuperSU в SYSTEM режиме (новые версии предпочитают
# режим SYSTEM-less, когда модифицируется boot.img и сам su устанавливается
# в образ ext4 /data/su.img, который монтируется на /su).
#
# Данный рецепт НЕ ИСПОЛЬЗУЕТСЯ т.к. не работает на x96max.
define INSTALL___SYSTEM
	echo -e "SYSTEMLESS=false\nPATCHBOOTIMAGE=false" >$/system/.supersu

	mkdir -p $/system/app/SuperSU
	unzip -qoj $(SUPERSU_ZIP) common/Superuser.apk -d $/system/app/SuperSU
	mv -f $/system/app/SuperSU/Superuser.apk $/system/app/SuperSU/SuperSU.apk

	unzip -qoj $(SUPERSU_ZIP) common/install-recovery.sh -d $/system/etc
	ln -fs /system/etc/install-recovery.sh $/system/bin/install-recovery.sh

	unzip -qoj $(SUPERSU_ZIP) armv7/su -d $/system/xbin

	mkdir -p $/system/bin/.ext
	cp -a $/system/xbin/su $/system/bin/.ext/.su

	cp -a $/system/xbin/su $/system/xbin/daemonsu

	unzip -qoj $(SUPERSU_ZIP) armv7/supolicy -d $/system/xbin

	unzip -qoj $(SUPERSU_ZIP) armv7/libsupol.so -d $/system/lib

	test -L $/system/bin/app_process32 || \
	cp -a $/system/bin/app_process32 $/system/bin/app_process32_original
	test -L $/system/bin/app_process32 || \
	cp -a $/system/bin/app_process32 $/system/bin/app_process_init
	ln -fs /system/xbin/daemonsu $/system/bin/app_process
	ln -fs /system/xbin/daemonsu $/system/bin/app_process32

	unzip -qoj $(SUPERSU_ZIP) common/99SuperSUDaemon -d $(SYSTEM)/system/etc/init.d

	touch $(SYSTEM)/system/etc/.installed_su_daemon

#	tools/img-perm -f $(DIR)supersu-system.perm -b $/
endef
