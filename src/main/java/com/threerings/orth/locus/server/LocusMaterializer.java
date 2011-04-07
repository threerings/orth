//
// $Id$

package com.threerings.orth.locus.server;

import com.samskivert.util.ResultListener;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.presents.data.ClientObject;

public interface LocusMaterializer
{
    void materializeLocus (ClientObject caller, Locus locus,
        ResultListener<HostedNodelet> listener);

    String getDSetName ();
}
