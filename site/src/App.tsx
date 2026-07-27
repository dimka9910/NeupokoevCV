const experience = [
  {
    role: "Job Title",
    company: "Company Name",
    period: "2023 — Present",
    summary: "One or two sentences about what you did in this role.",
  },
  {
    role: "Job Title",
    company: "Company Name",
    period: "2020 — 2023",
    summary: "One or two sentences about what you did in this role.",
  },
];

const skills = ["Java", "TypeScript", "AWS", "Terraform", "React", "SQL"];

function Section({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <section className="mx-auto max-w-2xl px-6 py-10">
      <h2 className="mb-4 text-xl font-semibold tracking-tight">{title}</h2>
      {children}
    </section>
  );
}

function App() {
  return (
    <main className="min-h-screen">
      <header className="border-b border-slate-200 dark:border-slate-800">
        <div className="mx-auto max-w-2xl px-6 py-16 text-center">
          <h1 className="text-4xl font-bold tracking-tight">
            Dmitrii Neupokoev
          </h1>
          <p className="mt-2 text-slate-500 dark:text-slate-400">
            Software Engineer
          </p>
        </div>
      </header>

      <Section title="About">
        <p className="text-slate-600 dark:text-slate-300">
          Placeholder bio — a couple of sentences about your background and
          what you're focused on.
        </p>
      </Section>

      <Section title="Experience">
        <ul className="space-y-6">
          {experience.map((job) => (
            <li key={`${job.company}-${job.period}`}>
              <div className="flex flex-wrap items-baseline justify-between gap-x-4">
                <span className="font-medium">
                  {job.role} · {job.company}
                </span>
                <span className="text-sm text-slate-500 dark:text-slate-400">
                  {job.period}
                </span>
              </div>
              <p className="mt-1 text-slate-600 dark:text-slate-300">
                {job.summary}
              </p>
            </li>
          ))}
        </ul>
      </Section>

      <Section title="Skills">
        <ul className="flex flex-wrap gap-2">
          {skills.map((skill) => (
            <li
              key={skill}
              className="rounded-full border border-slate-200 px-3 py-1 text-sm dark:border-slate-700"
            >
              {skill}
            </li>
          ))}
        </ul>
      </Section>

      <Section title="Contact">
        <p className="text-slate-600 dark:text-slate-300">
          <a
            className="underline underline-offset-4"
            href="mailto:you@example.com"
          >
            you@example.com
          </a>
        </p>
      </Section>

      <footer className="border-t border-slate-200 py-8 text-center text-sm text-slate-400 dark:border-slate-800">
        neupokoev.cv
      </footer>
    </main>
  );
}

export default App;
