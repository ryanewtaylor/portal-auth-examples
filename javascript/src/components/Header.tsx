import React from 'react';

interface HeaderProps {
    appTitle: string;
    user: string;
    onClickSignIn?: () => void;
    onClickSignOut?: () => void;
}

export const Header = ({ appTitle, user, onClickSignIn, onClickSignOut }: HeaderProps) => {
    return (
        <header className="header">
            <span>{appTitle}</span>
            {onClickSignIn && <button onClick={onClickSignIn}>Sign In</button>}
            {onClickSignOut && <span>{user}</span>}
            {onClickSignOut && <button onClick={onClickSignOut}>Sign Out</button>}
        </header>
    );
};
