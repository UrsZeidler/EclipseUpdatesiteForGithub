ECLIPSE=/var/lib/jenkins//tools/hudson.plugins.buckminster.BuckminsterInstallation/bucky_4.2/buckminster
SOURCE=http://valis:8080/view/shr/job/uml2solidity/ws/de.urszeidler.eclipse.solidity.p2/target/repository/

LOCAL_SITE=$WORKSPACE/uml2solidity-updatesite

SITE_NAME=uml2solidity-updatesite
## mirror maven build
echo " Mirroring metadata for $SOURCE "
java -jar $ECLIPSE/plugins/org.eclipse.equinox.launcher_*.jar \
     -application org.eclipse.equinox.p2.metadata.repository.mirrorApplication \
     -source $SOURCE \
     -destination $LOCAL_SITE \
     -destinationName "$SITE_NAME" \
     -verbose -ignoreErrors

echo " Mirroring artifacts for $SOURCE "
java -jar $ECLIPSE/plugins/org.eclipse.equinox.launcher_*.jar \
     -application org.eclipse.equinox.p2.artifact.repository.mirrorApplication \
     -source $SOURCE \
     -destination $LOCAL_SITE \
     -destinationName "$SITE_NAME" \
     -verbose -ignoreErrors

