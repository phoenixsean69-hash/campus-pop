.pragma library
// StudySpace built-in academic starter library. Educational reference content,
// not university-issued lecture notes or real assignment deadlines.
var library = {
  "STA 201": {
    "title": "Applied Statistics",
    "description": "Build reliable statistical reasoning: describe data, model uncertainty, estimate parameters and test claims using evidence.",
    "outcomes": [
      "Choose the right descriptive statistics and visualizations for a dataset.",
      "Calculate probabilities using conditional rules and standard distributions.",
      "Construct and interpret confidence intervals and hypothesis tests.",
      "Explain why a statistical result does or does not justify a practical conclusion."
    ],
    "topics": [
      {
        "title": "Data types and study design",
        "objective": "Distinguish populations, samples, variables and potential bias.",
        "lesson": "A population is the complete group of interest; a sample is the subset observed. Categorical variables describe classes, while quantitative variables measure amounts. Quantitative variables may be discrete counts or continuous measurements. Good analysis starts with a precise question, a sampling plan and awareness of selection bias. A sample can be large and still biased if some groups are systematically excluded.",
        "example": "A survey of 400 students selected from 8,000 enrolled students has population size 8,000 and sample size 400. If only library visitors were surveyed, the sampling frame may underrepresent students who study elsewhere.",
        "question": "Is year of study (1st, 2nd, 3rd, 4th) ordinal or nominal?",
        "answer": "Ordinal: the categories have a meaningful order, even though the distance between adjacent years is not a measured quantity."
      },
      {
        "title": "Descriptive statistics",
        "objective": "Calculate measures of center and spread and understand outliers.",
        "lesson": "The mean is the arithmetic average; the median is the middle value after sorting; the mode is the most frequent. Range equals maximum minus minimum. Variance averages squared deviations from the mean; standard deviation is its square root. Use the median and interquartile range when the distribution is skewed or contains extreme outliers. Charts must show labeled axes and appropriate scales.",
        "example": "For 2, 4, 4, 6, 9, the mean is 5, the median is 4 and the range is 7. Adding an extreme observation of 100 changes the mean far more than the median.",
        "question": "Which measure of center is usually more robust to a single extreme value?",
        "answer": "The median, because it depends on ordered position rather than the magnitude of every observation."
      },
      {
        "title": "Probability foundations",
        "objective": "Use complements, unions and intersections correctly.",
        "lesson": "Probability assigns values from 0 to 1 to events. The complement rule is P(not A)=1-P(A). For events A and B, P(A or B)=P(A)+P(B)-P(A and B); the intersection is subtracted because it was counted twice. If events are independent, P(A and B)=P(A)P(B). Mutually exclusive events cannot occur together, while independent events do not change one another's probabilities; these are different ideas.",
        "example": "If P(A)=0.6, P(B)=0.5 and P(A and B)=0.2, then P(A or B)=0.6+0.5-0.2=0.9.",
        "question": "Can two events with positive probabilities be both mutually exclusive and independent?",
        "answer": "No. Mutually exclusive events have P(A and B)=0, while independence with both probabilities positive requires P(A and B)=P(A)P(B)>0."
      },
      {
        "title": "Conditional probability and Bayes",
        "objective": "Update a probability when new evidence is observed.",
        "lesson": "Conditional probability is P(A given B)=P(A and B)/P(B), provided P(B)>0. Bayes' rule reverses the direction of conditioning: P(A given B)=P(B given A)P(A)/P(B). In diagnostic or classification problems, the base rate matters as much as sensitivity. Carefully distinguish the probability of evidence given a cause from the probability of a cause given evidence.",
        "example": "A condition affects 1% of people; a test detects 90% of cases and has a 5% false-positive rate. P(condition given positive)=0.9×0.01/(0.9×0.01+0.05×0.99)≈15.4%.",
        "question": "Why is a 90%-sensitive positive test not automatically a 90% chance of having the condition?",
        "answer": "Because sensitivity conditions on having the condition, while the requested probability conditions on testing positive; the prevalence and false-positive rate also matter."
      },
      {
        "title": "Discrete distributions",
        "objective": "Model counts using binomial and Poisson random variables.",
        "lesson": "A discrete random variable takes countable values. The binomial model counts successes across n independent trials with constant probability p: X~Bin(n,p), E[X]=np and Var(X)=np(1-p). The Poisson model counts events over a fixed exposure window when events occur independently at an approximately constant average rate λ: E[X]=Var(X)=λ. Check assumptions before choosing either model.",
        "example": "For 10 independent quiz questions with probability 0.6 of a correct answer, expected correct answers=10×0.6=6 and variance=10×0.6×0.4=2.4.",
        "question": "What is E[X] for a Poisson variable with λ=3.5?",
        "answer": "3.5. A Poisson random variable has mean and variance both equal to its rate parameter."
      },
      {
        "title": "Normal distribution and z-scores",
        "objective": "Standardize observations and read normal probabilities.",
        "lesson": "The normal distribution is continuous, symmetric and described by mean μ and standard deviation σ. Standardize x using z=(x-μ)/σ; z tells how many standard deviations x lies above or below the mean. The standard normal table or a statistical package converts z-scores into cumulative probabilities. The empirical 68–95–99.7 rule is an approximation, not a substitute for a precise calculation.",
        "example": "If scores are approximately normal with mean 70 and standard deviation 10, a score of 85 has z=(85-70)/10=1.5.",
        "question": "A measurement with z=-2 lies where relative to the mean?",
        "answer": "Two standard deviations below the mean."
      },
      {
        "title": "Confidence intervals",
        "objective": "Interpret interval estimates and their assumptions.",
        "lesson": "A confidence interval combines a point estimate with a margin of error. Under suitable assumptions, a large-sample confidence interval for a mean is x̄ ± z*σ/√n if population σ is known; use a t critical value and sample standard deviation when σ is unknown. A 95% confidence procedure captures the fixed population parameter across approximately 95% of repeated samples. It does not assign a 95% probability to a fixed parameter after observing one interval.",
        "example": "With x̄=50, known σ=12 and n=36, a 95% z interval is 50±1.96×12/6, or about (46.08, 53.92).",
        "question": "If sample size quadruples with variability unchanged, what happens to the standard error?",
        "answer": "It halves, because standard error is proportional to 1/√n."
      },
      {
        "title": "Hypothesis testing and interpretation",
        "objective": "Frame a test, compute a statistic and interpret p-values.",
        "lesson": "Specify the null H0, alternative H1, significance level α and a suitable test before examining the result. A p-value is the probability, assuming H0 and the test assumptions, of obtaining a statistic at least as extreme as the observed one. Reject H0 when p≤α; otherwise fail to reject it. Failing to reject is not proof that H0 is true. Also report effect size and practical importance: a tiny difference may be statistically significant in a very large sample.",
        "example": "A test returns p=0.03 with α=0.05. The result is statistically significant at the 5% level, but we still need the estimated effect and confidence interval.",
        "question": "Does p=0.03 mean there is a 3% probability the null hypothesis is true?",
        "answer": "No. It is a probability of data as extreme as observed under the null model, not the probability the null itself is true."
      }
    ],
    "materials": [
      {
        "title": "Statistics formula reference",
        "kind": "Reference sheet",
        "summary": "Core equations and symbols for revision.",
        "body": "Mean: x̄=Σx/n. Sample variance: s²=Σ(x-x̄)²/(n-1). Standard score: z=(x-μ)/σ. Addition rule: P(A∪B)=P(A)+P(B)-P(A∩B). Conditional probability: P(A|B)=P(A∩B)/P(B). Bayes: P(A|B)=P(B|A)P(A)/P(B). Binomial mean/variance: np / np(1-p). Standard error of a mean: s/√n. Always check assumptions and define notation."
      },
      {
        "title": "Choosing a statistical method",
        "kind": "Study guide",
        "summary": "Match a research question to an appropriate tool.",
        "body": "1. Describe one quantitative variable: mean/median, spread, histogram or boxplot. 2. Compare two independent group means: consider a two-sample t procedure if conditions hold. 3. Measure association of numerical variables: scatterplot and correlation; association is not causation. 4. Compare observed counts across categories: consider a chi-square test with adequate expected counts. 5. Estimate a mean: confidence interval with appropriate standard error. 6. Test a predefined claim: state hypotheses and report a p-value plus effect size."
      },
      {
        "title": "Revision exercises",
        "kind": "Practice set",
        "summary": "Numerical problems with answer checks.",
        "body": "A. For 5, 7, 7, 9, 12, calculate mean=8, median=7 and range=7. B. For independent events P(A)=0.3 and P(B)=0.4, P(A∩B)=0.12. C. For a normal score x=90, μ=75, σ=10, z=1.5. D. A binomial variable with n=20, p=0.25 has mean 5 and variance 3.75. Explain each assumption before applying a formula."
      }
    ],
    "assignments": [
      {
        "title": "Analyze a small dataset",
        "focus": "Descriptive statistics",
        "brief": "Choose 15–30 numerical observations (or use a supplied small dataset). Calculate mean, median, standard deviation and IQR; create one well-labeled chart and explain any outliers.",
        "deliverables": "A one-page report, calculation table and labeled chart.",
        "rubric": "Correct calculations 40%; visualization 25%; interpretation 25%; clarity 10%."
      },
      {
        "title": "Probability and inference problem set",
        "focus": "Probability and testing",
        "brief": "Solve a conditional probability question using Bayes, one binomial expectation problem and a confidence-interval problem. State assumptions and interpret results in ordinary language.",
        "deliverables": "Three worked solutions plus a short interpretation paragraph for each.",
        "rubric": "Correct method 35%; arithmetic 30%; assumptions 20%; interpretation 15%."
      }
    ]
  },
  "CSC 203": {
    "title": "Python Programming",
    "description": "Develop practical Python skills from clear control flow to modular, testable programs and object-oriented design.",
    "outcomes": [
      "Write readable programs with appropriate data structures.",
      "Decompose programs into functions and modules.",
      "Model objects using classes and exceptions safely.",
      "Write tests and handle files without losing or corrupting data."
    ],
    "topics": [
      {
        "title": "Values, variables and types",
        "objective": "Use expressions and choose appropriate types.",
        "lesson": "Python variables refer to objects and do not require type declarations. Common built-in types include int, float, str and bool. Operators follow precedence rules; parentheses improve clarity. Convert user input explicitly because input() returns a string. Use descriptive snake_case names and avoid overshadowing built-ins like list or sum.",
        "example": "price = 12.5; quantity = 3; total = price * quantity gives 37.5. int(\"4\") converts the string into an integer; int(\"four\") raises ValueError.",
        "question": "What is the type of input(\"Age: \") before conversion?",
        "answer": "str, even if the user typed digits."
      },
      {
        "title": "Conditions and loops",
        "objective": "Express decisions and repeat work safely.",
        "lesson": "if/elif/else selects branches based on boolean expressions. Comparison operators include ==, !=, < and >=; use and/or/not for logical combinations. for iterates over a sequence or range; while repeats while a condition is true. Avoid infinite loops by ensuring loop state progresses. continue skips to the next iteration; break exits the nearest loop.",
        "example": "sum_even = 0\nfor n in range(2, 11, 2):\n    sum_even += n\nThe final value is 30 (2+4+6+8+10).",
        "question": "What numbers are produced by range(1, 6, 2)?",
        "answer": "1, 3 and 5. The stop value 6 is excluded."
      },
      {
        "title": "Lists, tuples, sets and dictionaries",
        "objective": "Select a collection suited to the data.",
        "lesson": "Lists preserve order and can be changed; tuples preserve order and are immutable. Sets store unique elements and support membership and set operations. Dictionaries map unique keys to values. A membership test in a set or dictionary is typically efficient; a list is appropriate when sequence order and duplicates matter. Copies are important: assigning another variable to a list creates an alias, not a new list.",
        "example": "scores=[70,80,80]; unique=set(scores) yields {70,80}. student={\"name\":\"Tariro\",\"score\":80}; student[\"score\"] looks up the value by key.",
        "question": "Which collection best maps a course code to its course title?",
        "answer": "A dictionary, because each code is a key associated with one title."
      },
      {
        "title": "Functions and scope",
        "objective": "Break programs into testable units.",
        "lesson": "Define functions with def and provide parameters for inputs. Use return to send a result to the caller; print displays output but does not return the value. Local variables exist inside the function; avoid reliance on mutable global state. Default parameters are useful, but do not use a mutable list or dictionary as a default argument. Add docstrings that explain purpose, parameters and return value.",
        "example": "def percentage(part,total): return 100*part/total if total else 0. Calling percentage(18,24) returns 75.0.",
        "question": "What does a Python function return if no return statement executes?",
        "answer": "None."
      },
      {
        "title": "Classes and objects",
        "objective": "Model state and behavior with OOP.",
        "lesson": "A class defines a type; an instance is an object created from it. __init__ sets instance attributes. Methods take self to access the current instance. Encapsulation is the practice of providing coherent operations around data, rather than exposing internal details unnecessarily. Inheritance shares or extends behavior, and method overriding changes behavior in subclasses. Prefer composition when a has-a relationship better fits the design.",
        "example": "class Account:\n    def __init__(self, balance=0):\n        self.balance = balance\n    def deposit(self, amount):\n        self.balance += amount\nEach Account instance has its own balance.",
        "question": "Why is self included in instance-method definitions?",
        "answer": "It refers to the instance receiving the method call, allowing access to its data and methods."
      },
      {
        "title": "Files, paths and exceptions",
        "objective": "Read/write files and handle failure predictably.",
        "lesson": "Use with open(path, encoding=\"utf-8\") so file resources close when the block ends, even on failure. Modes include r for reading, w for overwriting and a for appending. Handle expected exceptions such as FileNotFoundError and ValueError specifically; broad except clauses can hide programming bugs. pathlib.Path is useful for cross-platform paths. Validate inputs before saving or parsing.",
        "example": "with open(\"notes.txt\", \"w\", encoding=\"utf-8\") as f:\n    f.write(\"Revision plan\")\nThe file closes automatically when the block exits.",
        "question": "What happens when opening an existing file in mode \"w\"?",
        "answer": "Its existing contents are truncated before new content is written."
      },
      {
        "title": "Modules, packages and environments",
        "objective": "Organize reusable Python programs.",
        "lesson": "A module is a .py file containing functions, classes and constants. A package groups related modules. Import statements let code reuse these definitions without duplicating implementation. The if __name__ == \"__main__\": guard runs a section only when the file is executed directly. A virtual environment isolates dependencies per project; requirements.txt records installed package versions.",
        "example": "In calculations.py: def add(a,b): return a+b. In main.py: from calculations import add; result = add(2,3). The result is 5. Put each statement on its own line in a real source file.",
        "question": "Why use a virtual environment for a PySide6 desktop project?",
        "answer": "To isolate its package versions from other Python projects and make setup reproducible."
      },
      {
        "title": "Testing and debugging",
        "objective": "Validate behavior with repeatable tests.",
        "lesson": "Unit tests check small pieces of behavior, including edge cases and failures. Use assertions to compare actual and expected values; make tests independent of one another. Logging provides context for failures, while breakpoints let you inspect variable values. When a bug appears, construct the smallest failing example and fix its cause rather than masking symptoms.",
        "example": "For percentage(part,total), test percentage(3,4)==75.0 and percentage(2,0)==0. Test invalid inputs separately if validation is part of the function contract.",
        "question": "Why test the case total=0 rather than only ordinary values?",
        "answer": "Because edge cases expose failure modes such as division by zero that happy-path tests miss."
      }
    ],
    "materials": [
      {
        "title": "Python syntax quick reference",
        "kind": "Reference sheet",
        "summary": "Core language patterns in one place.",
        "body": "Variables: total=0. Condition: if score>=50: passed=True. Loop: for item in items: print(item). Function: def square(x): return x*x. List comprehension: [x*x for x in range(5)]. Dictionary: grades={\"A\":80}. Safe file read: with open(path,encoding=\"utf-8\") as file: text=file.read(). Exception: try: value=int(raw) except ValueError: print(\"Invalid number\"). Module guard: if __name__ == \"__main__\": main()."
      },
      {
        "title": "OOP patterns and common mistakes",
        "kind": "Study guide",
        "summary": "Classes, instance state and inheritance.",
        "body": "Keep instance fields under self. Avoid sharing mutable class attributes accidentally between instances. Prefer small methods with clear responsibilities. Use super().__init__() when a subclass needs base initialization. Do not confuse __str__ with __repr__: the first is reader-friendly, the second is developer-oriented. Consider composition before inheritance to avoid fragile class hierarchies."
      },
      {
        "title": "Practice problems and checks",
        "kind": "Practice set",
        "summary": "Short programming problems with expected outputs.",
        "body": "1. Write a function that returns the maximum of three numbers. 2. Count word frequencies with a dictionary; for [\"a\",\"b\",\"a\"], expected result is {\"a\":2,\"b\":1}. 3. Create a Student class with name and marks; method average() should return the mean. 4. Read a CSV safely and skip malformed rows with useful logging. Test empty inputs and invalid values."
      }
    ],
    "assignments": [
      {
        "title": "Student grade calculator",
        "focus": "Functions and collections",
        "brief": "Implement a console program that stores multiple student marks, calculates averages and assigns grades using documented thresholds. Validate every mark is between 0 and 100.",
        "deliverables": "Python source, README with run instructions, at least five automated tests.",
        "rubric": "Correctness 45%; validation 20%; modularity 20%; tests and documentation 15%."
      },
      {
        "title": "Mini course organizer",
        "focus": "OOP and file handling",
        "brief": "Create Course and Student classes. Allow a student to enroll in courses, list enrollments and save/load records using JSON. Handle missing files and corrupt JSON gracefully.",
        "deliverables": "Python package, sample JSON file, tests for persistence and invalid data.",
        "rubric": "Design 30%; file operations 30%; error handling 20%; tests 20%."
      }
    ]
  },
  "CSC 214": {
    "title": "Computer Systems",
    "description": "Understand how processors, memory, operating systems, storage and networks work together to execute applications.",
    "outcomes": [
      "Explain instruction execution and major hardware components.",
      "Differentiate memory, virtual memory and storage.",
      "Describe how processes and threads share resources.",
      "Diagnose basic performance and reliability problems."
    ],
    "topics": [
      {
        "title": "Computer architecture",
        "objective": "Identify CPU, memory and I/O roles.",
        "lesson": "A computer system combines a CPU, main memory, persistent storage and input/output controllers. The CPU fetches instructions, decodes operations and executes them while registers hold frequently used values. The program counter identifies the next instruction, subject to branching. The buses and memory hierarchy affect overall throughput. The operating system coordinates access to these resources.",
        "example": "When a program computes a+b, the CPU loads operands into registers, performs an arithmetic operation and stores or uses the result. The compiler and instruction set determine the exact machine operations.",
        "question": "What hardware component normally holds program instructions while a program is running?",
        "answer": "Main memory (RAM), with frequently used instructions also cached nearer the CPU."
      },
      {
        "title": "Binary representation and logic",
        "objective": "Interpret bits, bytes and basic logical operations.",
        "lesson": "A bit stores 0 or 1; a byte usually contains 8 bits. Unsigned n-bit values range from 0 to 2^n-1. Two's complement is commonly used for signed integer representations. Hexadecimal groups binary digits into sets of four for readable notation. AND, OR, XOR and NOT are fundamental bitwise operations. Overflow occurs when a computed value exceeds the representation's capacity.",
        "example": "Binary 10110110 equals hexadecimal B6 (11×16+6=182 decimal). An unsigned 8-bit integer can store 0 through 255.",
        "question": "What is the largest unsigned value in 16 bits?",
        "answer": "2^16-1=65,535."
      },
      {
        "title": "CPU performance and caches",
        "objective": "Explain why CPU clock rate alone does not determine speed.",
        "lesson": "Execution time depends on instruction count, cycles per instruction and clock frequency. Modern CPUs also use pipelining, out-of-order execution and multi-level caches to reduce latency. Cache performance depends on locality: programs often reuse nearby data or recently accessed values. A cache miss must fetch data from a slower level. A CPU running at a higher frequency may still be slower on a workload with poor caching or more instructions.",
        "example": "A task requires 2×10^9 cycles on a 2 GHz CPU, giving an idealized execution time of roughly 1 second, ignoring overhead and changes in frequency.",
        "question": "Why can a sequential array traversal be faster than random pointer chasing?",
        "answer": "Sequential traversal has better spatial locality, leading to more effective cache-line reuse and prefetching."
      },
      {
        "title": "Memory hierarchy and virtual memory",
        "objective": "Differentiate registers, caches, RAM and virtual address spaces.",
        "lesson": "Registers and caches are fast and small; RAM is larger but slower; SSD/HDD storage is persistent but much slower for random access. Virtual memory gives each process a protected address space and maps virtual addresses to physical frames using page tables. A page fault occurs when a needed page is not currently mapped in accessible physical memory and requires operating-system handling; it is not always an error.",
        "example": "A 4 KiB page covers 4096 bytes. With 32-bit virtual addresses and 4 KiB pages, the offset uses 12 bits, leaving 20 bits for the virtual page number.",
        "question": "Does a page fault always mean the application has crashed?",
        "answer": "No. Some page faults are normal and handled by allocating/loading memory; invalid accesses may trigger a fault that terminates the process."
      },
      {
        "title": "Processes, threads and scheduling",
        "objective": "Describe process isolation and concurrency.",
        "lesson": "A process has its own virtual address space and resources. Threads within a process share its address space while maintaining separate execution contexts. The operating system scheduler assigns CPU time based on policy and priorities. Concurrency allows tasks to make progress in overlapping time periods; parallelism means simultaneous execution on multiple processing units. Context switches incur overhead.",
        "example": "A browser may use multiple processes for isolation and multiple threads inside each process for user interface and background work.",
        "question": "What do threads of one process normally share?",
        "answer": "The process address space and many resources, while each thread has its own stack and execution state."
      },
      {
        "title": "Synchronization and deadlocks",
        "objective": "Protect shared state across concurrent tasks.",
        "lesson": "Race conditions arise when a program's result depends on timing between operations. Mutexes protect critical sections, while semaphores coordinate access to limited resources. Deadlock can occur when tasks hold resources while waiting for one another in a cycle. A consistent lock acquisition order can help avoid circular wait. Minimize time in locked sections to reduce contention.",
        "example": "Two threads each increment a shared counter 1000 times. Without synchronization, the final counter may be less than 2000 if increments race.",
        "question": "Why is counter=counter+1 not always atomic?",
        "answer": "It can involve separate read, calculation and write operations that another thread may interleave."
      },
      {
        "title": "Storage systems and file systems",
        "objective": "Explain persistent data and reliability.",
        "lesson": "SSDs store data in flash memory and HDDs store it magnetically. File systems organize names, directories, metadata, permissions and file allocation. Caching improves throughput but creates durability concerns: data may remain in volatile memory until flushed. Backups and checksums help protect against corruption, while RAID is not a substitute for backups. File permissions and encryption protect access to stored information.",
        "example": "Saving a document updates application buffers, operating system caches and eventually persistent media. A sudden power loss can affect writes that were not safely committed.",
        "question": "Why is RAID not equivalent to a backup?",
        "answer": "RAID may protect against a drive failure but does not necessarily protect against accidental deletion, ransomware or corrupted content."
      },
      {
        "title": "Networks and system diagnostics",
        "objective": "Interpret latency, throughput and common failures.",
        "lesson": "Bandwidth is potential link capacity; throughput is the achieved data-transfer rate. Latency measures delay and jitter measures variation in delay. Packet loss can result from congestion, interference or faults. Diagnose problems systematically: check physical connection, IP configuration, local reachability, DNS and remote service health. Monitoring CPU, RAM, disk and network together prevents incorrect conclusions.",
        "example": "A 100 MB transfer over a nominal 100 Mb/s link takes at least about 8 seconds before protocol overhead, because 100 MB≈800 Mb.",
        "question": "Can low latency guarantee high throughput?",
        "answer": "No. Throughput also depends on bandwidth, loss, protocol behavior and system bottlenecks."
      }
    ],
    "materials": [
      {
        "title": "Hardware and OS glossary",
        "kind": "Reference sheet",
        "summary": "Essential terms for computer systems.",
        "body": "CPU: executes machine instructions. Register: very fast CPU storage. Cache: stores copies of frequently used memory. RAM: volatile working memory. Process: isolated program instance. Thread: execution path within a process. Scheduler: selects runnable tasks. Page table: maps virtual pages to physical frames. Context switch: switching active execution context. File system: organizes persistent storage."
      },
      {
        "title": "Memory hierarchy diagram guide",
        "kind": "Study guide",
        "summary": "Visualize the trade-offs between speed, size and cost.",
        "body": "Draw levels from CPU registers, L1/L2/L3 cache, RAM, SSD and HDD. Label decreasing typical speed and increasing typical capacity as you move outward. Explain spatial and temporal locality. Then add virtual memory: virtual address -> page table translation -> physical frame. Distinguish a cache miss from a page fault."
      },
      {
        "title": "Troubleshooting checklist",
        "kind": "Lab guide",
        "summary": "A structured approach to diagnosing slow or unstable systems.",
        "body": "1. Reproduce and describe the symptom. 2. Record CPU, RAM, disk and network utilization during the event. 3. Check logs and recent updates. 4. Isolate one possible cause at a time. 5. Try reversible changes first. 6. Re-test and document before/after behavior. Back up important data before invasive disk operations or OS reinstalls."
      }
    ],
    "assignments": [
      {
        "title": "Memory and CPU walkthrough",
        "focus": "Architecture",
        "brief": "Draw and annotate the path from source code to machine execution, including CPU registers, caches, RAM and persistent storage. Include a worked virtual-page offset example.",
        "deliverables": "Annotated architecture diagram and a 600–800 word explanation.",
        "rubric": "Accuracy 45%; labels 25%; example 20%; presentation 10%."
      },
      {
        "title": "Concurrency and performance study",
        "focus": "OS concepts",
        "brief": "Explain a producer-consumer scenario with shared state, propose a synchronization strategy and describe two performance measurements you would record.",
        "deliverables": "Short design report with pseudocode, expected risks and a measurement plan.",
        "rubric": "Concurrency model 35%; synchronization 30%; measurement 20%; clarity 15%."
      }
    ]
  },
  "SWE 210": {
    "title": "Software Engineering",
    "description": "Take software from stakeholder needs to maintainable, tested delivery through disciplined processes and design decisions.",
    "outcomes": [
      "Elicit and prioritize verifiable software requirements.",
      "Choose suitable design boundaries and interfaces.",
      "Plan tests and manage changes safely.",
      "Communicate project risk, scope and quality to stakeholders."
    ],
    "topics": [
      {
        "title": "Software lifecycle and process models",
        "objective": "Choose a process suited to uncertainty and risk.",
        "lesson": "Software engineering combines requirements, design, construction, verification, release and maintenance. A plan-driven model emphasizes defined stages and documentation, while iterative models revisit requirements and deliver increments. Agile practices shorten feedback cycles but still need design and quality discipline. There is no universally best process: regulatory constraints, team size, change rate and dependencies affect the choice.",
        "example": "A student portal with uncertain feature priorities may benefit from short iterative releases; firmware for safety-critical infrastructure may require stronger traceability and formal review.",
        "question": "Why might a one-pass waterfall approach struggle when requirements change weekly?",
        "answer": "Late changes can invalidate earlier design and tests, causing expensive rework before users see the product."
      },
      {
        "title": "Requirements engineering",
        "objective": "Write testable functional and nonfunctional requirements.",
        "lesson": "Functional requirements describe capabilities; nonfunctional requirements specify qualities or constraints such as performance, availability and security. Use stakeholder interviews, observation and prototypes to uncover needs. Each requirement should be understandable, feasible, unambiguous and verifiable. Acceptance criteria define what must be observed before work is accepted.",
        "example": "Weak: \"the app should be fast.\" Better: \"for 95% of searches over 10,000 records, results appear within 2 seconds under the specified workload.\"",
        "question": "Is \"the system shall send a password-reset email\" functional or nonfunctional?",
        "answer": "Functional: it describes a behavior the system must perform."
      },
      {
        "title": "UML and system modelling",
        "objective": "Use diagrams to communicate boundaries and behavior.",
        "lesson": "Use-case diagrams show actors and high-level interactions; sequence diagrams show message order across components; class diagrams show types and relationships. Activity diagrams model workflow and decisions. A model simplifies reality to answer a specific question; adding every implementation detail can make a diagram less useful. Keep names consistent with the requirements.",
        "example": "For course registration, a sequence diagram might include Student UI -> Enrollment Service -> Database -> Confirmation, showing validation and failure alternatives.",
        "question": "Which UML diagram best explains the order of messages in a login request?",
        "answer": "A sequence diagram."
      },
      {
        "title": "Modularity and design principles",
        "objective": "Reduce coupling and make responsibilities clear.",
        "lesson": "Cohesion measures how closely responsibilities within a module belong together; coupling measures dependency between modules. Prefer high cohesion and low coupling. Encapsulate changing details behind stable interfaces. The single responsibility principle encourages a module to have one reason to change. Good design supports testability and avoids over-engineering abstractions that offer no clear benefit.",
        "example": "An EnrollmentService should manage enrollment rules rather than generating PDF reports and drawing UI widgets in the same class.",
        "question": "Why is a database call from every UI button often difficult to maintain?",
        "answer": "It mixes presentation and data access, increasing coupling and making testing and future backend changes harder."
      },
      {
        "title": "Version control and collaboration",
        "objective": "Use branches, reviews and meaningful commits.",
        "lesson": "Version control records changes and makes collaboration manageable. Keep commits small and descriptive; use feature branches for isolated work and pull requests or code reviews to catch defects. Resolve merge conflicts by understanding intent, not blindly choosing one side. Keep secrets and generated build artifacts out of source control. Use issue tracking to connect work to requirements and tests.",
        "example": "Commit message \"Add validation for duplicate course codes\" conveys more useful history than \"changes\".",
        "question": "What should you do before merging a feature branch?",
        "answer": "Run relevant checks, review the diff, handle conflicts and ensure intended tests pass."
      },
      {
        "title": "Software testing strategy",
        "objective": "Select unit, integration and system tests.",
        "lesson": "Unit tests isolate small functions. Integration tests verify interactions between components. System tests exercise end-to-end workflows. Regression tests check that existing behavior still works after a change. The test pyramid encourages many fast unit tests with fewer expensive end-to-end checks. Boundary values and invalid input often expose errors that ordinary examples miss.",
        "example": "For registration, test that a valid user can register, an existing email is rejected, passwords meet policy and data persists after restart.",
        "question": "Why are only end-to-end tests insufficient?",
        "answer": "They may be slow and brittle, and failures often give less precise information about which unit broke."
      },
      {
        "title": "Quality, security and maintainability",
        "objective": "Plan for software behavior beyond the happy path.",
        "lesson": "Quality includes reliability, usability, performance, security and maintainability. Security practices include least privilege, input validation, secure credential handling and dependency patching. Observability through structured logs and metrics helps diagnose production issues. Accessibility matters for keyboard use, contrast and screen-reader support. Maintainability requires clear naming, modular boundaries and reasonable documentation.",
        "example": "A student records service should enforce permissions server-side, not rely solely on hiding unauthorized buttons in the UI.",
        "question": "Does client-side validation remove the need for server-side validation?",
        "answer": "No. Clients can be bypassed or modified; the trusted server must enforce its own rules."
      },
      {
        "title": "Project estimation and delivery",
        "objective": "Manage scope, risk and releases realistically.",
        "lesson": "Break work into small deliverables and identify dependencies. Estimates should include integration, testing, packaging and unknowns, not only coding time. Maintain a risk register with probability, impact and mitigation. Define \"done\" with acceptance criteria and evidence. Releasing a small reliable version is preferable to promising a large version with hidden defects.",
        "example": "A desktop release plan includes feature completion, data migration testing, installer checks, rollback and user documentation—not just finishing the UI.",
        "question": "What is the purpose of a definition of done?",
        "answer": "To establish shared, verifiable conditions that must hold before a work item is considered complete."
      }
    ],
    "materials": [
      {
        "title": "Requirements template",
        "kind": "Template",
        "summary": "Create clearer functional requirements and acceptance criteria.",
        "body": "ID: FR-001. Title: Search courses. Description: A signed-in student can filter courses by name or code. Inputs: query text. Preconditions: student has access to the course catalog. Expected result: matching courses displayed. Acceptance: case-insensitive matching; empty query returns all; no result shows a clear empty state. Nonfunctional target: 95th-percentile response within an agreed limit under specified load."
      },
      {
        "title": "Testing checklist",
        "kind": "Reference sheet",
        "summary": "Use before a feature is considered complete.",
        "body": "Have unit tests covered business rules and edge cases? Have integration tests checked external dependencies? Are accessibility, keyboard operation and contrast acceptable? Do failure messages explain next steps? Are secrets excluded from logs? Does the feature work after a restart? Is behavior documented and reviewed? Has a rollback method been considered?"
      },
      {
        "title": "Design review worksheet",
        "kind": "Study guide",
        "summary": "Challenge architecture choices with targeted questions.",
        "body": "For each module ask: What responsibility does it own? What inputs and outputs are public? Which assumptions can fail? Is this information duplicated elsewhere? Can the module be tested independently? What could change next semester? Which security boundary applies? What evidence supports using this abstraction instead of a simpler implementation?"
      }
    ],
    "assignments": [
      {
        "title": "Study planner requirements specification",
        "focus": "Requirements",
        "brief": "Draft functional and nonfunctional requirements for a university study planner. Provide three user stories and explicit acceptance criteria. Identify at least two failure paths.",
        "deliverables": "Requirements document, user-story table and acceptance-test checklist.",
        "rubric": "Clarity 25%; testability 35%; coverage 25%; traceability 15%."
      },
      {
        "title": "Test plan for course registration",
        "focus": "Software testing",
        "brief": "Design unit, integration and user-acceptance tests for a course-registration feature. Include normal, boundary, invalid and unauthorized scenarios.",
        "deliverables": "Test matrix with inputs, expected outputs, priorities and dependencies.",
        "rubric": "Coverage 40%; correct expectations 30%; risk prioritization 20%; clarity 10%."
      }
    ]
  },
  "MTH 220": {
    "title": "Discrete Mathematics",
    "description": "Develop the mathematical tools for rigorous software reasoning: logic, sets, counting, relations, graphs and proofs.",
    "outcomes": [
      "Translate statements into formal logic and check validity.",
      "Apply set, relation and function concepts.",
      "Count arrangements using systematic methods.",
      "Reason about graphs, algorithms and mathematical proofs."
    ],
    "topics": [
      {
        "title": "Propositional logic",
        "objective": "Evaluate logical operators and truth values.",
        "lesson": "A proposition is a statement that is either true or false. Connectives include negation ¬P, conjunction P∧Q, disjunction P∨Q and implication P→Q. An implication is false only when P is true and Q is false. Truth tables establish equivalence and validity of compound expressions. De Morgan's laws state ¬(P∧Q) ≡ ¬P∨¬Q and ¬(P∨Q) ≡ ¬P∧¬Q.",
        "example": "If P is true and Q is false, P→Q is false, P∨Q is true and P∧Q is false.",
        "question": "Is P→Q logically equivalent to ¬P∨Q?",
        "answer": "Yes. They have identical truth values for every assignment of P and Q."
      },
      {
        "title": "Predicate logic and quantifiers",
        "objective": "Distinguish universal and existential claims.",
        "lesson": "Predicates become propositions when variables are assigned values or bound by quantifiers. The universal quantifier ∀ means \"for all\" and the existential quantifier ∃ means \"there exists\". Their negations switch quantifier type: ¬∀x P(x) is ∃x ¬P(x); ¬∃x P(x) is ∀x ¬P(x). Quantifier order matters when multiple variables appear.",
        "example": "Negation of \"Every student has submitted\" is \"At least one student has not submitted\", not \"No student submitted\".",
        "question": "Negate ∃x P(x).",
        "answer": "∀x ¬P(x): P holds for no element in the domain."
      },
      {
        "title": "Sets and operations",
        "objective": "Compute unions, intersections, differences and products.",
        "lesson": "A set is a collection of distinct elements. A∪B includes elements in either set, A∩B includes elements common to both and A\\B includes elements in A but not B. For finite sets, |A∪B|=|A|+|B|-|A∩B|. The Cartesian product A×B contains ordered pairs (a,b). A power set contains all subsets of a set.",
        "example": "A={1,2,3} and B={3,4}. A∪B={1,2,3,4}, A∩B={3}, and A×B has 3×2=6 ordered pairs.",
        "question": "How many subsets does a set of five elements have?",
        "answer": "2^5=32, including the empty set and the original set."
      },
      {
        "title": "Relations and functions",
        "objective": "Test properties of relations and mappings.",
        "lesson": "A binary relation on A is a subset of A×A. It is reflexive if every (a,a) belongs to it, symmetric if (a,b) implies (b,a), and transitive if (a,b) and (b,c) imply (a,c). An equivalence relation has all three properties and partitions a set into equivalence classes. A function maps each input to exactly one output; injective means distinct inputs produce distinct outputs, surjective means every codomain element is reached.",
        "example": "The relation \"has the same remainder modulo 3\" on integers is an equivalence relation. Its classes are numbers congruent to 0, 1 or 2 mod 3.",
        "question": "Can a function assign two different outputs to the same input?",
        "answer": "No. That violates the definition of a function."
      },
      {
        "title": "Counting and combinatorics",
        "objective": "Apply product rules, permutations and combinations.",
        "lesson": "If one stage has m choices and another independent stage has n choices, the product rule gives mn outcomes. Permutations count ordered selections: nPr=n!/(n-r)!. Combinations count unordered selections: nCr=n!/[r!(n-r)!]. The pigeonhole principle says distributing n+1 objects into n boxes forces at least one box to contain two objects. Be explicit whether order matters and repetition is allowed.",
        "example": "Selecting 3 students from 10 for an unordered team gives C(10,3)=120. Assigning president, secretary and treasurer gives P(10,3)=720.",
        "question": "How many ways can you choose 2 people from 5 when order does not matter?",
        "answer": "C(5,2)=10."
      },
      {
        "title": "Proof methods",
        "objective": "Construct valid arguments using several strategies.",
        "lesson": "A direct proof starts from premises and derives the target statement. Proof by contrapositive proves ¬Q→¬P instead of P→Q. Proof by contradiction assumes the negation of the conclusion and obtains an impossibility. Mathematical induction proves a base case and shows that if the claim holds for n then it holds for n+1. Examples support conjectures but do not prove statements for all integers.",
        "example": "To prove the sum of two even integers is even, write a=2m and b=2n. Then a+b=2(m+n), which is even.",
        "question": "What are the two main steps in mathematical induction?",
        "answer": "Prove the base case; then prove the inductive step from n to n+1."
      },
      {
        "title": "Graphs and trees",
        "objective": "Describe vertices, edges and common graph structures.",
        "lesson": "A graph G=(V,E) has vertices and edges. Degree counts incident edges in an undirected graph; the handshaking lemma says the sum of degrees equals 2|E|. Paths connect vertices and cycles return to the start. A tree is a connected graph with no cycles; a tree with n vertices has n-1 edges. Graphs model routes, dependencies, networks and many scheduling problems.",
        "example": "A connected acyclic graph with 8 vertices has 7 edges. If an extra edge joins two already-connected vertices, a cycle appears.",
        "question": "How many edges does a tree with 12 vertices have?",
        "answer": "11."
      },
      {
        "title": "Recurrence and algorithm analysis",
        "objective": "Reason about recursive definitions and growth rates.",
        "lesson": "A recurrence defines a sequence or complexity in terms of earlier values, such as T(n)=T(n-1)+n. Big-O notation describes asymptotic upper growth, ignoring constant factors for sufficiently large inputs. Typical classes include O(1), O(log n), O(n), O(n log n) and O(n²). Correct analysis identifies loop nesting, recurrence structure and input assumptions rather than counting one run.",
        "example": "A nested loop over all pairs in an n-element list performs roughly n² iterations, so its time complexity is O(n²).",
        "question": "What is the time complexity of binary search on a sorted array?",
        "answer": "O(log n), because each comparison reduces the remaining search range by about half."
      }
    ],
    "materials": [
      {
        "title": "Logic identities",
        "kind": "Reference sheet",
        "summary": "Frequently used equivalences and transformations.",
        "body": "Identity: P∧True=P; P∨False=P. Domination: P∨True=True; P∧False=False. Idempotent: P∧P=P. Double negation: ¬¬P=P. De Morgan: ¬(P∧Q)=¬P∨¬Q; ¬(P∨Q)=¬P∧¬Q. Implication: P→Q=¬P∨Q. Contrapositive: P→Q=¬Q→¬P. Use truth tables to verify unfamiliar identities."
      },
      {
        "title": "Counting decision guide",
        "kind": "Study guide",
        "summary": "Choose the right counting method.",
        "body": "Ask: are choices made in stages? Use multiplication. Is the order relevant? For selecting r unique items from n: if order matters use nPr; otherwise use nCr. Is repetition allowed? For r positions with n possible values each, n^r strings result. Does placing more objects than containers force a repeat? Use pigeonhole. Write assumptions before calculating."
      },
      {
        "title": "Graph theory examples",
        "kind": "Practice set",
        "summary": "Short graph and tree exercises.",
        "body": "1. A tree with 15 vertices has 14 edges. 2. In any undirected graph, the number of odd-degree vertices is even. 3. A complete undirected graph on 5 vertices has 5×4/2=10 edges. 4. A cycle graph with 6 vertices has 6 edges. 5. Draw a graph with an Euler trail but no Euler circuit: it must have exactly two vertices of odd degree, assuming relevant connectivity."
      }
    ],
    "assignments": [
      {
        "title": "Logic and proof portfolio",
        "focus": "Formal reasoning",
        "brief": "Build truth tables for three compound statements, write one direct proof and one contradiction or contrapositive proof. Explain each step using logical laws.",
        "deliverables": "Truth tables and two complete proofs, with each law cited.",
        "rubric": "Logical validity 45%; complete reasoning 35%; notation 10%; clarity 10%."
      },
      {
        "title": "Networks as graphs",
        "focus": "Graph theory",
        "brief": "Model a small campus route network as a graph with at least eight locations. Identify degrees, paths, cycles and a spanning tree. Explain one algorithmic use of the graph.",
        "deliverables": "Labeled graph diagram and short analytical report.",
        "rubric": "Graph model 30%; correct properties 35%; spanning tree 20%; explanation 15%."
      }
    ]
  },
  "CSC 216": {
    "title": "Database Systems",
    "description": "Design reliable data models, write useful SQL queries and understand integrity, transactions and database security.",
    "outcomes": [
      "Create clear entity-relationship and relational models.",
      "Write SQL queries involving joins and aggregation.",
      "Normalize common designs and justify keys and constraints.",
      "Explain transactions, indexes, permissions and backups."
    ],
    "topics": [
      {
        "title": "Database concepts and DBMS",
        "objective": "Describe the role of a database management system.",
        "lesson": "A database stores related data in a structured way. A DBMS handles querying, data integrity, permissions, transactions and recovery. Relational databases organize records into tables; other database models prioritize document, key-value or graph structures. Separate the conceptual data model from implementation details, and distinguish a schema (definition) from its current data (instance).",
        "example": "For a university, a DBMS stores Students, Courses and Enrollments. Applications query and update these tables without each implementing their own low-level file organization.",
        "question": "What is the difference between a schema and a database instance?",
        "answer": "The schema defines structure and constraints; the instance is the actual data at a particular moment."
      },
      {
        "title": "Entity-relationship modelling",
        "objective": "Turn requirements into entities and relationships.",
        "lesson": "An ER model identifies entities, attributes, keys and relationships. Cardinality describes whether one entity can relate to one or many of another. An associative entity resolves many-to-many relationships. Optional participation should be explicitly considered. Names should represent real domain concepts; avoid storing the same fact redundantly across unrelated entities.",
        "example": "Students and Courses have a many-to-many relationship; an Enrollment entity links student_id and course_id and may store enrolled_at or grade.",
        "question": "How would you represent students registering for multiple courses and each course having many students?",
        "answer": "Use an associative Enrollment table/entity with foreign keys to Student and Course."
      },
      {
        "title": "Relational keys and constraints",
        "objective": "Protect data integrity using database rules.",
        "lesson": "A primary key uniquely identifies each row and is not null. A foreign key refers to a key in another table, helping enforce referential integrity. UNIQUE prevents duplicate values in a key candidate; NOT NULL ensures required fields exist; CHECK enforces simple predicates. Referential actions such as RESTRICT and CASCADE should be chosen deliberately to avoid accidental data loss.",
        "example": "Student(student_id PRIMARY KEY, email UNIQUE NOT NULL) and Enrollment(student_id REFERENCES Student(student_id)) prevent invalid references if foreign-key enforcement is enabled.",
        "question": "Can a primary key contain NULL?",
        "answer": "No. A primary key must uniquely identify each row and is not nullable."
      },
      {
        "title": "SQL SELECT and filtering",
        "objective": "Query and sort records with clear conditions.",
        "lesson": "SELECT chooses columns from a data source; WHERE filters rows before grouping, ORDER BY sorts the final result, and LIMIT restricts output in supported SQL dialects. Use meaningful aliases and avoid SELECT * in production-facing queries where a stable schema is valuable. SQL NULL represents missing or unknown information, so use IS NULL rather than = NULL.",
        "example": "SELECT name FROM students WHERE year_of_study >= 2 ORDER BY name; returns second-year-and-above students alphabetically.",
        "question": "Why does WHERE email = NULL not work as intended?",
        "answer": "NULL comparisons use three-valued logic; use WHERE email IS NULL."
      },
      {
        "title": "Joins and aggregation",
        "objective": "Combine relational tables and summarize groups.",
        "lesson": "INNER JOIN returns matching rows, while LEFT JOIN retains all left-side rows and fills missing right-side values with NULL. Join using the correct foreign-key relationship to avoid unintended Cartesian products. GROUP BY partitions rows into groups; COUNT, SUM, AVG and other aggregates compute summaries; HAVING filters groups after aggregation.",
        "example": "SELECT c.title, COUNT(e.student_id) AS total FROM courses c LEFT JOIN enrollments e ON e.course_id=c.id GROUP BY c.id,c.title; includes courses with zero enrollments.",
        "question": "What distinguishes HAVING from WHERE?",
        "answer": "WHERE filters input rows before grouping; HAVING filters groups after aggregation."
      },
      {
        "title": "Normalization and anomalies",
        "objective": "Recognize and reduce redundant data.",
        "lesson": "Normalization organizes relations to avoid update, insertion and deletion anomalies. First normal form expects atomic field values rather than repeating groups. Second normal form addresses dependencies on only part of a composite key; third normal form removes transitive dependencies among nonkey attributes. Normalization trades some join complexity for integrity and maintainability. Denormalization should be intentional and measured.",
        "example": "If Enrollment(student_id, course_id, student_name, course_title) repeats names for every enrollment, separate Student and Course attributes into their own tables.",
        "question": "What problem occurs if a student name is repeated across many enrollment rows?",
        "answer": "An update anomaly: changing the name requires coordinated updates to multiple rows and can leave inconsistent values."
      },
      {
        "title": "Transactions and ACID",
        "objective": "Explain atomic updates and isolation.",
        "lesson": "A transaction groups operations into a unit. Atomicity means all-or-nothing, consistency enforces valid transitions, isolation controls interference between concurrent transactions and durability preserves committed results after failures. Locking and multiversion concurrency control (MVCC) are common implementations. Isolation levels balance anomalies, throughput and concurrency; a transaction may need retries after a deadlock or serialization conflict.",
        "example": "Moving funds between accounts requires subtracting from one account and adding to another within one transaction; a failure must roll back both changes.",
        "question": "What does atomicity guarantee?",
        "answer": "Either every operation in the transaction commits, or none of them does."
      },
      {
        "title": "Indexes, access control and backups",
        "objective": "Balance query speed, permissions and reliability.",
        "lesson": "Indexes accelerate certain lookups and joins by maintaining extra search structures, but they require storage and slow some writes. Use query plans to decide which indexes help. Grant the least database privileges needed by each role; avoid sharing administrator credentials with applications. Backups must be tested by restoring them, not merely by creating files. Plan retention and recovery targets.",
        "example": "An index on enrollments(course_id) can improve frequent searches for all students in a course, but adds maintenance overhead when enrollments change.",
        "question": "Can an index improve every query without cost?",
        "answer": "No. Indexes consume space, may not help some plans and add write overhead."
      }
    ],
    "materials": [
      {
        "title": "SQL quick reference",
        "kind": "Reference sheet",
        "summary": "Core relational-query building blocks.",
        "body": "SELECT name FROM students WHERE year_of_study=2; SELECT c.title, COUNT(*) FROM enrollments e JOIN courses c ON c.id=e.course_id GROUP BY c.id,c.title; INSERT INTO students(id,name) VALUES(1,'Ada'); UPDATE students SET name='Ada K.' WHERE id=1; DELETE FROM enrollments WHERE id=7; Use transactions for related writes and parameterized queries for untrusted input."
      },
      {
        "title": "University ER modelling checklist",
        "kind": "Study guide",
        "summary": "How to review a relational design.",
        "body": "Identify entities, their primary keys and required attributes. Check cardinality and optional relationships. Resolve many-to-many relationships with linking tables. Specify foreign-key rules, uniqueness and NULL policy. Identify attributes duplicated across tables. Document expected queries and sensitive data access. Finally, test insertions and deletions for referential integrity."
      },
      {
        "title": "Transactions and indexes reference",
        "kind": "Study guide",
        "summary": "Remember ACID and performance trade-offs.",
        "body": "A=atomicity, C=consistency, I=isolation, D=durability. COMMIT makes successful changes permanent, ROLLBACK reverses uncommitted work. Indexes speed up selected lookups but increase write/storage overhead. Use EXPLAIN/EXPLAIN QUERY PLAN when available to observe query execution. Backups must include periodic restore tests and appropriate access control."
      }
    ],
    "assignments": [
      {
        "title": "Design a university enrollment database",
        "focus": "ER modelling and SQL",
        "brief": "Design Student, Course, Lecturer and Enrollment entities with correct cardinalities and constraints. Provide a relational schema and SQL CREATE TABLE statements for your chosen DBMS.",
        "deliverables": "ER diagram, schema documentation and SQL script.",
        "rubric": "Relationship modelling 30%; keys and constraints 35%; SQL correctness 25%; clarity 10%."
      },
      {
        "title": "SQL reporting and integrity lab",
        "focus": "Joins and transactions",
        "brief": "Insert representative sample rows, write at least five queries including one LEFT JOIN and one GROUP BY, and demonstrate a transaction that rolls back after an error.",
        "deliverables": "SQL script, expected result tables and a short explanation of transaction behavior.",
        "rubric": "Query logic 40%; integrity 25%; transaction 25%; explanation 10%."
      }
    ]
  }
};

function findCourse(code) {
    return library[String(code)] || null;
}
