package com.threerings.orth.comms.data;

import com.threerings.orth.data.ModuleStreamable;
import com.threerings.orth.data.OrthName;

public abstract class BaseOneToOneComm extends ModuleStreamable
    implements OneToOneComm
{
    public BaseOneToOneComm (OrthName from, OrthName to)
    {
        _from = from;
        _to = to;
    }

    @Override
    public OrthName getTo ()
    {
        return _to;
    }

    @Override
    public OrthName getFrom ()
    {
        return _from;
    }


    protected OrthName _from, _to;
}
