import React from 'react';
import ReactDOM from 'react-dom';

import { Header } from './components/Header';
import { AppProvider } from './contexts/App';

import { title } from './config';
import OAuthInfo from 'esri/identity/OAuthInfo';
import esriId from 'esri/identity/IdentityManager';
import Portal from 'esri/portal/Portal';

const portalUrl = 'HTTPS://YOUR.PORTAL.COM/PORTAL';

var info = new OAuthInfo({
    portalUrl: portalUrl,
    appId: 'YOUR_CLIENT_ID',
    popup: false,
});

const handleSignIn = () => {
    esriId.getCredential(info.portalUrl + '/sharing');
};

const handleSignOut = () => {
    esriId.destroyCredentials();
    window.location.reload();
};

esriId.registerOAuthInfos([info]);

esriId
    .checkSignInStatus(info.portalUrl + '/sharing')
    .then(() => {
        const portal = new Portal({ url: portalUrl, authMode: 'immediate' });
        // portal.load(() => {
            console.log('portal loaded: ' + portal.user.username);
            ReactDOM.render(
                <AppProvider>
                    <Header appTitle={title} user={portal.user.username} onClickSignOut={handleSignOut} />
                    <div>Authenticated!</div>
                </AppProvider>,
                document.getElementById('root'),
            );
        // });
    })
    .catch(() => {
        ReactDOM.render(
            <AppProvider>
                <></>
                <Header appTitle={title} user={''} onClickSignIn={handleSignIn} />
            </AppProvider>,
            document.getElementById('root'),
        );
    });
