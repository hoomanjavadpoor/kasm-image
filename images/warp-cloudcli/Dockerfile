FROM kasmweb/core-ubuntu-jammy:1.19.0-rolling-daily
USER root

ENV HOME       /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

## Configure single-application XFCE desktop, remove panel, set black wallpaper
COPY shared/scripts/set_bg_black.sh $INST_SCRIPTS/shared/set_bg_black.sh
RUN cp "$HOME/.config/xfce4/xfconf/single-application-xfce-perchannel-xml/"* \
       "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/" \
    && apt-get remove -y xfce4-panel \
    && bash "$INST_SCRIPTS/shared/set_bg_black.sh" \
    && rm -f "$INST_SCRIPTS/shared/set_bg_black.sh"

## Base tools (Go + Python 3)
COPY shared/scripts/install_base_tools.sh $INST_SCRIPTS/shared/install_base_tools.sh
RUN bash "$INST_SCRIPTS/shared/install_base_tools.sh" \
    && rm -rf "$INST_SCRIPTS/shared/"

## Cloud CLIs (az, aws, gcp, gh)
COPY shared/scripts/install_cloudclis.sh $INST_SCRIPTS/shared/install_cloudclis.sh
RUN bash "$INST_SCRIPTS/shared/install_cloudclis.sh" \
    && rm -rf "$INST_SCRIPTS/shared/"

## Default browser (Firefox) – needed for OAuth / cloud CLI login flows
COPY shared/scripts/install_browser.sh $INST_SCRIPTS/shared/install_browser.sh
RUN bash "$INST_SCRIPTS/shared/install_browser.sh" \
    && rm -rf "$INST_SCRIPTS/shared/"

## Warp Terminal + cloud CLIs
COPY images/warp-cloudcli/src/install_warp.sh $INST_SCRIPTS/warp/install_warp.sh
RUN bash "$INST_SCRIPTS/warp/install_warp.sh" \
    && rm -rf "$INST_SCRIPTS/warp/"

## Startup script
COPY images/warp-cloudcli/src/custom_startup.sh $STARTUPDIR/custom_startup.sh
RUN chmod 755 "$STARTUPDIR/custom_startup.sh"

######### End Customizations ###########

RUN chown 1000:0 "$HOME"
RUN $STARTUPDIR/set_user_permission.sh "$HOME"

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p "$HOME" && chown -R 1000:0 "$HOME"

USER 1000
