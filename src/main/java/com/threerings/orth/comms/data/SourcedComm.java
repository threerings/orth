package com.threerings.orth.comms.data;

import com.threerings.orth.aether.data.PlayerName;

public interface SourcedComm
{
    PlayerName getSource();
}
