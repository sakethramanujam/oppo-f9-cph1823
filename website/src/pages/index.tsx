import type {ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

import styles from './index.module.css';

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={siteConfig.title}
      description="Unlock, dump, OrangeFox, and Android 13 GSI for Oppo F9 CPH1823. No warranty. GrapheneOS unavailable.">
      <header className={clsx('hero hero--primary', styles.heroBanner)}>
        <div className="container">
          <Heading as="h1" className="hero__title">
            {siteConfig.title}
          </Heading>
          <p className="hero__subtitle">{siteConfig.tagline}</p>
          <div className={styles.buttons}>
            <Link className="button button--secondary button--lg" to="/docs/">
              Open Runbook
            </Link>
          </div>
        </div>
      </header>
      <main>
        <section className="container margin-vert--lg">
          <div className="alert alert--danger" role="alert">
            <strong>No warranty. High brick risk.</strong> Only use on a device
            you own. Unlock and flash steps can permanently brick the phone.
          </div>
          <p className="margin-top--md">
            Runbook for Oppo F9 / F9 Pro (<strong>CPH1823</strong>, MediaTek{' '}
            <strong>MT6771</strong>): unlock, partition dump, OrangeFox, Android
            13 Treble GSI.
          </p>
          <p>
            <strong>GrapheneOS is not available on this device.</strong> An
            unlocked bootloader plus an unsigned GSI{' '}
            <strong>weakens</strong> Android Verified Boot relative to locked
            stock. This is not GrapheneOS-class security.
          </p>
          <p>
            <Link to="/docs/">Continue to the overview and phase docs →</Link>
          </p>
        </section>
      </main>
    </Layout>
  );
}
