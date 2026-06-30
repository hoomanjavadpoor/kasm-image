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

## AnyDesk
COPY images/anydesk/src/install_anydesk.sh $INST_SCRIPTS/anydesk/install_anydesk.sh
RUN bash "$INST_SCRIPTS/anydesk/install_anydesk.sh" \
    && rm -rf "$INST_SCRIPTS/anydesk/"

## Startup script
COPY images/anydesk/src/custom_startup.sh $STARTUPDIR/custom_startup.sh
RUN chmod 755 "$STARTUPDIR/custom_startup.sh"

######### End Customizations ###########

RUN chown 1000:0 "$HOME"
RUN $STARTUPDIR/set_user_permission.sh "$HOME"

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p "$HOME" && chown -R 1000:0 "$HOME"

USER 1000
