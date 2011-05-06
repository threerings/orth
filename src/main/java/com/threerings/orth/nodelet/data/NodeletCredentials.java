package com.threerings.orth.nodelet.data;

import com.threerings.orth.data.TokenCredentials;

public class NodeletCredentials extends TokenCredentials
{
    /** An optional reference to a server object address. This is for use by orth subsystems as
     * they see fit. If null, the subsystem does not use it. */
    public Object object;

    protected void toString (StringBuilder buf)
    {
        super.toString(buf);
        if (object != null) {
            buf.append(", object=").append(object);
        }
    }
}
