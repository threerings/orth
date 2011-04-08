//
// $Id$

package com.threerings.orth.locus.server;

import com.samskivert.util.ResultListener;

import com.threerings.orth.data.AuthName;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.nodelet.data.HostedNodelet;

public interface LocusMaterializer
{
    void materializeLocus (AuthName caller, Locus locus, ResultListener<HostedNodelet> listener);

    String getDSetName ();
}
