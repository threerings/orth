package com.threerings.orth.guild.client
{
import flashx.funk.ioc.Module;
import flashx.funk.ioc.inject;

import com.threerings.util.Log;

import com.threerings.presents.dobj.AttributeChangeListener;
import com.threerings.presents.dobj.AttributeChangedEvent;
import com.threerings.presents.dobj.ChangeListener;
import com.threerings.presents.dobj.DObject;

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.guild.data.GuildObject;
import com.threerings.orth.nodelet.client.NodeletDirector;

public class GuildDirector extends NodeletDirector
    implements AttributeChangeListener
{
    public function GuildDirector()
    {
        super("hostedGuilds");
    }

    public function attributeChanged (event :AttributeChangedEvent) :void
    {
        if (event.getName() == PlayerObject.GUILD) {
            connect(_plobj.guild);
        }
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

    protected var _guildObj :GuildObject;
    protected var _module :Module = inject(Module);
    private static const log :Log = Log.getLog(GuildDirector);
}
}
