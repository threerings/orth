//
// $Id: PartyClientResolver.java 19629 2010-11-24 16:40:04Z zell $

package com.threerings.orth.party.server;

import com.google.inject.Inject;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.ClientResolver;

import com.threerings.orth.aether.data.VizPlayerName;
import com.threerings.orth.data.MediaDesc;

import com.threerings.orth.person.server.persist.ProfileRecord;
import com.threerings.orth.person.server.persist.ProfileRepository;

import com.threerings.orth.party.data.PartierObject;
import com.threerings.orth.party.data.PartyAuthName;

/**
 * Handles the resolution of partier client information.
 */
public class PartyClientResolver extends ClientResolver
{
    @Override // from PresentsClientResolver
    public ClientObject createClientObject ()
    {
        return new PartierObject();
    }

    @Override // from PresentsSession
    protected void resolveClientData (ClientObject clobj)
        throws Exception
    {
        super.resolveClientData(clobj);

        PartierObject partObj = (PartierObject)clobj;
        PartyAuthName authName = (PartyAuthName)_username;

        MemberRecord member = _memberRepo.loadMember(authName.getId());
        ProfileRecord precord = _profileRepo.loadProfile(member.memberId);
        MediaDesc photo = (precord == null) ? OrthName.DEFAULT_PHOTO : precord.getPhoto();

        // NOTE: we avoid using the dobject setters here because we know the object is not out in
        // the wild and there's no point in generating a crapload of events during user
        // initialization when we know that no one is listening
        partObj.playerName = new VizPlayerName(member.name, member.memberId, photo);
    }

    @Inject protected MemberRepository _memberRepo;
    @Inject protected ProfileRepository _profileRepo;
}
