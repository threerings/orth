package com.threerings.orth.guild.client
{
import flashx.funk.ioc.inject;

import com.threerings.util.Log;

import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.dobj.AttributeChangeListener;
import com.threerings.presents.dobj.AttributeChangedEvent;
import com.threerings.presents.dobj.ChangeListener;
import com.threerings.presents.util.SafeSubscriber;

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.nodelet.client.NodeletDirector;

public class GuildDirector extends NodeletDirector
    implements AttributeChangeListener
{
    public function GuildDirector()
    {
        _octx.getClient().addEventListener(ClientEvent.CLIENT_DID_LOGON, setupPlayer);
        _octx.getClient().addEventListener(ClientEvent.CLIENT_DID_LOGOFF, setupPlayer);
        _octx.getClient().addEventListener(ClientEvent.CLIENT_OBJECT_CHANGED, setupPlayer);
    }

    override protected function refreshPlayer () :void
    {
        if (_plobj != null) {
            _plobj.removeListener(this);
            _plobj = null;
        }

        super.refreshPlayer();

        if (_plobj != null) {
            _plobj.addListener(this);
            connect(_plobj.guild);
        } else {
            disconnect();
        }
    }

    override protected function objectAvailable (obj :DObject) :void
    {
        super.objectAvailable(obj);
        _guildObj = GuildObject(obj);
    }

    public function attributeChanged (event :AttributeChangedEvent) :void
    {
        if (event.getName() == PlayerObject.GUILD) {
            event.getOldValue()
        }
    }

    private static const log :Log = Log.getLog(GuildDirector);
}
}
