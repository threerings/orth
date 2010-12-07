package com.threerings.orth.client
{
import com.threerings.presents.net.AuthResponseData;
import com.threerings.presents.util.PresentsContext;

public interface OrthContext
    extends PresentsContext
{
    function saveSessionToken (arsp :AuthResponseData) :void;
}
}
