"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import {
  GraduationCap, School, Users, BookOpen, CalendarCheck,
  CreditCard, BarChart3, ShieldCheck, TrendingUp, Clock,
  ArrowRight, ArrowLeft, ChevronRight, ChevronLeft, Menu, X
} from "lucide-react";
import { useTranslation, getLang } from "@/core/i18n/i18n";
import { LanguageSwitcher } from "@/shared/ui/LanguageSwitcher";
import { StatCard } from "@/shared/ui/StatCard";
import { motion, Variants } from "framer-motion";

export default function LandingPage() {
  const { t, isAr, mounted } = useTranslation();
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenu, setMobileMenu] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 40);
    window.addEventListener("scroll", onScroll);
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  const staticText = isAr ? "دير مدرستك بالكامل" : "Run Your Entire";
  const animatedText = isAr ? "من لوحة تحكم واحدة جبارة" : "School from One Powerful Dashboard";

  // Ultra-Premium Entrance Animation (No disappearing)
  const entranceVariant: Variants = {
    hidden: { 
      y: 15, 
      opacity: 0, 
      filter: "blur(12px)", 
      scale: 0.95 
    },
    visible: { 
      y: 0, 
      opacity: 1, 
      filter: "blur(0px)", 
      scale: 1,
      transition: {
        duration: 1.2,
        ease: [0.22, 1, 0.36, 1], // Extremely smooth cinematic deceleration
        delay: 0.2 // Small delay to let the page load first
      }
    }
  };

  const logos = [
    "🏫 Future Leaders",
    "📚 Al Noor Academy",
    "🎓 Bright Minds",
    "📖 Horizon Schools",
    "🏛️ Al Azhar Int'l"
  ];

  return (
    <div className="landing-page">
      {/* ── NAVIGATION ── */}
      <nav className={`landing-nav ${scrolled ? "scrolled" : ""}`}>
        <div className="nav-brand">
          <div className="logo-icon"><GraduationCap size={22} /></div>
          <h3>Edu<span>Control</span></h3>
        </div>
        <div className="nav-links">
          <a href="#features">{t('' as any)}</a>
          <a href="#how">{t('' as any)}</a>
          <a href="#testimonials">{t('' as any)}</a>
        </div>
        <div className="nav-actions">
          <Link href="/login" className="btn">{t('' as any)}</Link>
          <Link href="/register" className="btn primary">
            {t('' as any)} {isAr ? <ChevronLeft size={16} /> : <ChevronRight size={16} />}
          </Link>
          <LanguageSwitcher />
        </div>
        <button className="mobile-menu-toggle" onClick={() => setMobileMenu(!mobileMenu)}>
          {mobileMenu ? <X size={24} color="#fff" /> : <Menu size={24} color="#fff" />}
        </button>
      </nav>

      {/* ── HERO ── */}
      <section className="hero-section">
        <div className="hero-bg-effects">
          <div className="orb orb-1" />
          <div className="orb orb-2" />
          <div className="orb orb-3" />
        </div>
        <div className="hero-grid-pattern" />

        <div className="hero-container">
          <div className="hero-content">
            <div className="hero-badge">
              <span className="dot" />
              {t('' as any)}
            </div>

            <h1 style={{ minHeight: isAr ? "120px" : "140px" }}>
              {staticText}{" "}
              <motion.span
                variants={entranceVariant}
                initial="hidden"
                animate="visible"
                className="gradient-text"
                style={{ display: "inline-block" }}
              >
                {animatedText}
              </motion.span>
            </h1>

            <p style={{ marginTop: "16px" }}>
              {t('' as any)}
            </p>
            <div className="hero-actions">
              <Link href="/register" className="btn primary lg">
                {t('' as any)}  {isAr ? <ArrowLeft size={18} /> : <ArrowRight size={18} />}
              </Link>
              <Link href="/login" className="btn outline lg">
                {t('' as any)}
              </Link>
            </div>
            <div className="hero-stats">
              <div className="hero-stat">
                <div className="number">250+</div>
                <div className="label">{t('' as any)}</div>
              </div>
              <div className="hero-stat">
                <div className="number">50K+</div>
                <div className="label">{t('' as any)}</div>
              </div>
              <div className="hero-stat">
                <div className="number">99.9%</div>
                <div className="label">{t('' as any)}</div>
              </div>
            </div>
          </div>

          <div className="hero-visual">
            <div className="hero-image-wrapper">
              <img src="/hero-dashboard.png" alt="EduControl Dashboard" />
              <div className="hero-float-card card-1">
                <div className="card-icon">📊</div>
                <div className="card-label">Attendance Rate</div>
                <div className="card-value">96.4%</div>
              </div>
              <div className="hero-float-card card-2">
                <div className="card-icon">🎓</div>
                <div className="card-label">Active Students</div>
                <div className="card-value">1,248</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── TRUSTED BY ── */}
      <section className="trusted-section">
        <div className="trusted-container">
          <p>{t('' as any)}</p>
          <div className="trusted-logos-wrapper">
            <div className="trusted-logos">
              {[...logos, ...logos].map((logo, index) => (
                <span key={index}>{logo}</span>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* ── STATS ── */}
      <section className="stats-section">
        <div className="stats-container">
          <StatCard icon={<School size={24} color="#1d4ed8" />} end={250} suffix="+" label={t('' as any)} />
          <StatCard icon={<Users size={24} color="#1d4ed8" />} end={50000} suffix="+" label={t('' as any)} />
          <StatCard icon={<TrendingUp size={24} color="#1d4ed8" />} end={40} suffix="%" label={t('' as any)} />
          <StatCard icon={<Clock size={24} color="#1d4ed8" />} end={99} suffix=".9%" label={t('' as any)} />
        </div>
      </section>

      {/* ── FEATURES ── */}
      <section className="features-section" id="features">
        <div className="section-header">
          <div className="section-label"><span className="line" /> {t('' as any)} <span className="line" /></div>
          <h2>{t('' as any)}</h2>
          <p>{t('' as any)}</p>
        </div>
        <div className="features-grid">
          {[
            { icon: <Users size={24} color="#1d4ed8" />, title: t('' as any), desc: t('' as any) },
            { icon: <BookOpen size={24} color="#1d4ed8" />, title: t('' as any), desc: t('' as any) },
            { icon: <CalendarCheck size={24} color="#1d4ed8" />, title: t('' as any), desc: t('' as any) },
            { icon: <CreditCard size={24} color="#1d4ed8" />, title: t('' as any), desc: t('' as any) },
            { icon: <BarChart3 size={24} color="#1d4ed8" />, title: t('' as any), desc: t('' as any) },
            { icon: <ShieldCheck size={24} color="#1d4ed8" />, title: t('' as any), desc: t('' as any) },
          ].map((feature) => (
            <div className="feature-card" key={feature.title}>
              <div className="feature-icon">{feature.icon}</div>
              <h3>{feature.title}</h3>
              <p>{feature.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* ── HOW IT WORKS ── */}
      <section className="how-section" id="how">
        <div className="how-container">
          <div className="section-header">
            <div className="section-label"><span className="line" /> {t('' as any)} <span className="line" /></div>
            <h2>{t('' as any)}</h2>
            <p>{t('' as any)}</p>
          </div>
          <div className="how-grid">
            <div className="how-step">
              <div className="step-number">1</div>
              <h3>{t('' as any)}</h3>
              <p>{t('' as any)}</p>
            </div>
            <div className="how-step">
              <div className="step-number">2</div>
              <h3>{t('' as any)}</h3>
              <p>{t('' as any)}</p>
            </div>
            <div className="how-step">
              <div className="step-number">3</div>
              <h3>{t('' as any)}</h3>
              <p>{t('' as any)}</p>
            </div>
          </div>
        </div>
      </section>

      {/* ── TESTIMONIALS ── */}
      <section className="testimonials-section" id="testimonials">
        <div className="section-header">
          <div className="section-label"><span className="line" /> {t('' as any)} <span className="line" /></div>
          <h2>{t('' as any)}</h2>
          <p>{t('' as any)}</p>
        </div>
        <div className="testimonials-grid">
          {[
            {
              stars: 5,
              quote: t('' as any),
              name: "Ahmed Hassan",
              role: t('' as any),
              avatar: "A"
            },
            {
              stars: 5,
              quote: t('' as any),
              name: "Sara Ibrahim",
              role: t('' as any),
              avatar: "S"
            },
            {
              stars: 5,
              quote: t('' as any),
              name: "Dr. Mona Khalil",
              role: t('' as any),
              avatar: "M"
            }
          ].map((tItem) => (
            <div className="testimonial-card" key={tItem.name}>
              <div className="testimonial-stars">
                {Array.from({ length: tItem.stars }).map((_, i) => (
                  <span key={i}>★</span>
                ))}
              </div>
              <blockquote>"{tItem.quote}"</blockquote>
              <div className="testimonial-author">
                <div className="testimonial-avatar">{tItem.avatar}</div>
                <div className="testimonial-info">
                  <cite>{tItem.name}</cite>
                  <span>{tItem.role}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* ── CTA ── */}
      <section className="cta-section">
        <div className="cta-container">
          <h2>{t('' as any)}</h2>
          <p>{t('' as any)}</p>
          <div className="cta-actions">
            <Link href="/register" className="btn primary lg">
              {t('' as any)} {isAr ? <ArrowLeft size={18} /> : <ArrowRight size={18} />}
            </Link>
            <Link href="/login" className="btn outline lg">{t('' as any)}</Link>
          </div>
        </div>
      </section>

      {/* ── FOOTER ── */}
      <footer className="landing-footer">
        <div className="footer-container">
          <div className="footer-brand">
            <h3><School size={22} /> EduControl</h3>
            <p>{t('' as any)}</p>
          </div>
          <div className="footer-col">
            <h4>{t('' as any)}</h4>
            <a href="#features">{t('' as any)}</a>
            <a href="#how">{t('' as any)}</a>
            <a href="#">{t('' as any)}</a>
            <a href="#">{t('' as any)}</a>
          </div>
          <div className="footer-col">
            <h4>{t('' as any)}</h4>
            <a href="#">{t('' as any)}</a>
            <a href="#">{t('' as any)}</a>
            <a href="#">{t('' as any)}</a>
          </div>
          <div className="footer-col">
            <h4>{t('' as any)}</h4>
            <a href="#">{t('' as any)}</a>
            <a href="#">{t('' as any)}</a>
          </div>
        </div>
        <div className="footer-bottom">
          <span>© {new Date().getFullYear()} EduControl. All rights reserved.</span>
        </div>
      </footer>
    </div>
  );
}
