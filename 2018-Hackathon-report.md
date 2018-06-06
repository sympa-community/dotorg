**Disclaimer: This document expresses the views of the 2018 hackathon attendees. Consider all the points described as request for comments. This document should be the only reference for further discussions about the topics tackled during that hackathon.**

**Another disclaimer: I tried to have strictly separated sections in this report to ease further discussion; That means that you need to read the full report before reacting: some topics are related (for example, technology choice and decision making) and they are located in different sections.**

# 2018 Sympa Hackathon report
The 2018 Sympa hackathon was held in Strasbourg, France, from 22 to 24 of May.
It was organized by Marc Chantreux, from RENATER, and hosted by the Strasbourg university.

## Attendees
Here is the list of the attendees and their main areas of expertise (in last name - or handle - alphabetical order).

 - [Marc Chantreux](https://github.com/eiro) (RENATER): Perl expert, listmaster, Perlude creator
 - [Luc Didry](https://github.com/ldidry) (Framasoft): Framasoft listmaster, Sysadmin, Perl expert and experienced free software manager
 - [Mathieu Durero](https://github.com/mdrditarthur) (French young researchers confederation - CJC): "The noob": Mathieu is an experienced listmaster but didn't know anything about Perl or Ansible prior to the hackathon. His "naive" - though thoughtfull - input has been very valuable during the three days.
 - [François Menabe](https://github.com/fmenabe) (Strasbourg University): Sysadmin, Ansible expert
 - [Racke](https://github.com/racke) (Linuxia.de): Debian package developer, member of the Dancer2 community, Linux and Perl expert
 - [Olivier Salaün](https://github.com/salaun-urennes1) (Rennes university): Sympa creator, Devops expert,
 - [David Verdin](https://github.com/dverdin) (RENATER): Former Sympa lead developer, experienced listmaster

Other people also came and went during the three days, stopping by for a short discussion and then leaving, but the list above contains those who remained most of the three days.

## Preamble

The main problem in Sympa development is that, considering the large opportunities of evolution that awaits the software, it is very hard to know where to start working on it; and considering the heterogeneity of the community, it is very hard to know *how* to work.

Don't get me wrong: most people know exactly how and where *they* should start. Problem is: their personal point of view is, at best, only partially shared by other.

Consequently, amongst the three days of the hackathon, the first two were merely dedicated to discussions and the last one to actual coding experimentations.

The good news is that we achieved to agree on several points which could be very promising starts and, hopefully, lead to make actual progress in Sympa 7.0 development and in community involvement.

Here is the list of points discussed and the agreements we reached.

## Desirable future application design

 - **All the code should be testable**, with both unit tests on modules and functional tests on features.
 - **The code should expose several interfaces**: REST, web, CLI, mail. SOAP could be deprecated once a REST interface implements at least the same set of features.
 - All Sympa executables (being daemons, web process or command line) should make use of a **business object layer** which should be independant from the **persistance layer**.
 - Reminder: during last year hackathon, we already agreed on using the following technologies:
   - [Dancer2](https://metacpan.org/pod/Dancer2) for the REST API implementation,
   - [OpenAPI](https://github.com/OAI/OpenAPI-Specification) for the REST API specification,
   - [DBIx::Class](https://metacpan.org/pod/DBIx::Class) for Sympa database backend management and access.


## Sympa 7.0 target and methods of development

### Target

As we will not have the perfect Sympa right now, we should set some goals. A reasonable aim for Sympa 7.0 would be:

  * to be iso-functional with a refactored, testable code,
  * to expose a full REST API.

Below is a proposed methodology:
 - work on new technologies implementation,
 - code refactoring.

### Work on new technologies implementation

Write a Dancer2+DBIC proof of concept. Racke volunteers to work on it. The REST API would run on Dancer2 and directly query the database through DBIC. This would create a good base for future Sympa with actually running code.

### Code refactoring

**Important: this section exposes a general approcah to handle refactoring. The details of the CPAN modules implied and the coding style are in next section.**

The best way to have a backward-compatible Sympa 7 is to start from existing code and refactor it.

This would be done by following these steps:

- Create a testing framework to run *unit tests* on existing code (including mock databases, configurations, list directories, etc.). David volunteers to work on it.
- Create *functional tests* based on the [sympa-ansible project](https://github.com/sympa-community/sympa-ansible) and [Test::BDD::Cucumber](https://metacpan.org/pod/distribution/Test-BDD-Cucumber/lib/Test/BDD/Cucumber/Manual/Tutorial.pod). Olivier volunteers to work on it.
- Improve the code step by step. Anyone can do this. **That implies that we refactor the existing code. Though it will quickly derive from current 6.2, we would start from the same state.**

#### A proposed tagging system to track refactoring:

**Warning: This section contains ideas developped by Olivier and David while in the train back home. They were not discussed in such terms with the other.**

This is the suggested approach to track refactoring progress.
We could track changes through *comments in the Perl code*. These comments would have the following structure

```
  # WORK: <task>: <state>
```
  with:
```
  <task> = unit-tests|Moo|function-parameters|types-standard|<any other improvement we could do>
  <state>: FIXME|DONE|ONGOING:<username>
```
  - `FIXME` means that nothing has been done yet,
  - `DONE` means that this particular task is finished,
  - `ONGOING` would tell that somebody is currently working on this task for this module. <username> should be Github username.
 
Example: 
```
  # WORK: unit-tests: DONE
  # WORK: Moo: ONGOING:racke
  # WORK: Function-parameters: FIXME
  # WORK: types-standard: FIXME
```

That way, anyone could know how far we are by simply reading the module.

In addition, Travis CI could parse these tags and create a report about refactoring progress.

We even could add a progression tracker to the main Sympa web site.

## Coding practices

The aim of the discussion was to find a way to get rid of the *infrastructure code*. That's the part of the code that handles language mechanics instead of focusing on application logic. For example, the "bless" command used to cast anything into an object could be easily replaced by Moo.

We agreed on adding dependencies to a boilerplate module ([Sympatic](https://metacpan.org/release/Sympatic)), thus facilitating the application of these practices anywhere in the Sympa code.

### What we agreed on

All these modules allow to drastically decrease the number of Sympa code lines without changing anything in the application logic. It would make the code more readable and less error-prone.

Baring any strong opposition from the community, developers should use it when working on Sympa (don't forget to add those modules in the `cpanfile` with a description).

 - [use Moo](https://metacpan.org/pod/Moo): for *object orientation*,
 - [use Types::Standard](https://metacpan.org/pod/Types::Standard): to make *type checking* both automatic and explicit in the code,
 - [use Function::Parameters](https://metacpan.org/pod/Function::Parameters): to get functions (and object methods) signatures,
 - [use Path::Tiny](https://metacpan.org/pod/Path::Tiny): for any filesystem manipulation.

### What we did not agree on

  - [use MooX::LValueAttribute](https://metacpan.org/pod/MooX::LvalueAttribute): would allow to use attributes getters and setters as simple attribute, such as in `$self->attribute = $value;`.
  - [use autodie](https://metacpan.org/pod/autodie): throws a `die` whenever a system call fails. In addition to reservations regarding the autodie principle, the main concern was that dying is only half the job in exception systems. We also need an exception handling methodology. Without a concrete proposal about it, raising exception will only unstabilize the software.
  - [use do](http://perldoc.perl.org/functions/do.html): there was a proposal to use `do` whenever possible to make variable affectations explicit when they require complex code; the discussion reached no actual consensus. For now, if you want to use `do`, well, do it, but this would not be enforced as a coding style.
  - [use utf8::all](https://metacpan.org/pod/utf8::all): thought using it would make sense in a pure web environment, the diversity of data handled by Sympa, especially in emails, make encoding issues complex. It is impossible to use it until we have a complete testing framework and advice from people very well learned in this topic.


Pseudo-cyclomatic complexity removal. That means, replacing this:
```
if ($a ne 'value') {
  return $a;
} else {
  return 'value';
}
```
With this:
```
$a ne 'value' and return $a;
return $value;
```

Some people liked the brevity of the code. Other preferred the explicit structure. No consensus either on this topic.

### What is left aside for now

  - Functional programming: looks like a hot stuff right now but far from being a priority. Once the code is greatly improved, we might have new contributors that demand we switch to this; well, we'll see then.

### Coding style

Luc started working on a coding style. Everything is summed up in [this issue](https://github.com/sympa-community/sympa/issues/325).

## Community

Luc stressed out the fact that, currently, self organization of the community is weak and that newcomers have difficulties to know where to start. We won't achieve anything without a good coordination.

Here are a few things that were approved by the hackathon attendees.

### Semantic versioning

Here is the [semantic versioning](https://semver.org/) pattern, adopted by a large number of softwares:

`<major>.<minor>.<patch>`

Example:

`6.2.23`

  - **<major>**: non backward-compatible changes to the API;
  - **<minor>**: backward-compatible new functionnalities
    - if even (2, 4, 6...): stable release,
    - if odd (1, 3, 5, ...): unstable release;
  - **<patch>**: backward-compatible bug fixes.

The current way of Sympa versioning is atypical and prone to instill confusion to users. Non reversible and unstabilizing changes are introduced to the only active branch. Consequently, people upgrading Sympa can have broken features when they should expect only bug fixes.

Changing the way we version is possible right now (replacing the 6.2.33 with 6.3.0 for example). It is just a matter of communication: 
  - send a message to the lists,
  - display clear information on the Sympa web site and sympa project github Readme.md file.

### Single entry point for Sympa

For clarity purpose, we need a single entry point for people willing to get information about Sympa.

The best tool for this seems to be the sympa.org web site.

However, we need to allow community members to easily improve content of this web site. The tactics adopted by Soji to reorganize the Sympa manual can be reproduced for the rest of the site: have content sources on github, so that anyone willing to improve it can do it using pull requests.

We suggest to use two repositories: the current sympa-community.github.io for manual, and another one for the rest of the site. The manual is quite specific and Soji already did a lot of work on it.
That leads to the following actions:

 - Current www.sympa.org (a Dokuwiki-powered site) will be moved to dokuwiki.sympa.org or archive.sympa.org domain for backup.
 - [sympa-community.github.io](https://github.com/sympa-community/sympa-community.github.io) remains the central point for editing documentation.
 - A new repository is created ([dotorg](https://github.com/sympa-community/dotorg)) to handle:
   - organisation of the Sympa project,
   - an entry point for the community,
   - links to release tarballs,
   - contributing guidelines,
   - events / news / announces.

All data stored in Github are Markdown.

Marc Chantreux was mandated by the attendees to produce a first web site using these data. He works with Pandoc to generate web pages from Markdown.

He's following this workflow:
  - move dokuwiki data to Github,
  - translate dokuwiki syntax to Markdown,
  - use Pandoc again to populate a web site.

All website-related data (both from dotorg and sympa-community.github.io repositories) will be displayed on this website.

The good point of this approach is to make web content independent from hosting. If the current hosting structure (RENATER) became deficient, community would still retain the data and would easily move to another hosting service.

**NB** a few days after the hackathon, Soji raised [questions](https://listes.renater.fr/sympa/arc/sympa-developpers/2018-05/msg00042.html) about that website:
- Who is the person in charge on this issue?
- Who maintains (watch) the service running?
  If RENATER techies help, how can we contact them in urgent cases?
  Otherwise, who mainly maintains them?
- How can we do with crash (including crash of VM host)?
- Who deals with queries from users about services? (e.g. I can't see Sympa site! Is the server running?)
- What services may be run on the server?
- Are we allowed super-user access to the server (Otherwise, what interface is provided to manage server)? [I want this]
- How long the VM will be maintained? (e.g. until person in charge leaves community)
- What kind of regulations by RENATER are there to use their VM?
- When the older servers (www, demo, pootle, ...) will be shut down?
  How about translation process (e.g. HTTP redirection).
- etc.

Those questions should be addressed, but we should remember, when discussing about them, that there are other Sympa tools that have the same problem: sympa-* ML for example.

Any concern related to Sympa web site - and tools - hosting should be discussed on a Github issue in the [web site project](https://github.com/sympa-community/dotorg/issues).

### Decision making

A simple decision-making process is as follows:

 - Dude asks a question.
 - Other dudes discuss the question.
 - A result is output, that closes discussion.

In order to implement that process: 
  - Points that need discussions will lead to the creation of an issue on sympa.github.io, referencing the thread on the ML or the IRC archive.
  - People discuss on the original media of discussion: ML, IRC, Github issue, etc.
  - If a question is stagnant, it should be re-activated to reach a result. That implies that we should check regularly Github issues.
  - If a question has a result, the Github issue should be closed.
  
Advantage: no more dying threads on ML that are forgotten because other threads came in your email folder

### Ease newcomers enrolment

 - Use the "newcomer" tag in issues,
 - point from sympa.org to a pre-filtered link on github containing only issues for newcomers,
 - contribution guidelines should also be pointed from sympa.org,
 - use sympa-ansible and ansible-webmail-server repositories to offer a reproducible and easy to setup development environment,
 - unite these points in a "starter guide".

### Have a roadmap

Use milestones in Github to help tracking what is expected to be found in next Sympa releases.

Deprecations should be announced soon to help people prepare for it. And possibly discuss these deprecations.

### Make a Sympa conference

We made a lot during last year to make Sympa developers work together. It's good but, that said, other parts of the population should benefit from community cohesion.

Organizing a Sympa conference would be a very great opportunity to gather the different kind of people from the community (administrators, translators, packagers, end users, etc.).

The idea would be to have that kind of events:

  - report about the development progress,
  - focus on specific Sympa usages (large lists, clusters, lightweight instances, etc.),
  - speeches from active people (Racke, Soji, etc.),
  - workshops on specific usages (families, scenarios, etc.).

We could start with something small, at more or less zero cost, hosted by a university for free.
