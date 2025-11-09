package com.futurex.services.FutureXCourseApp;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.Tracer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigInteger;
import java.util.List;

@RestController
public class CourseController {

    private static final Logger logger = LoggerFactory.getLogger(CourseController.class);

    @Autowired
    private CourseRepository courseRepository;

    @Autowired
    private Tracer tracer;

    @Autowired
    private MeterRegistry meterRegistry;

    @RequestMapping("/")
    public String getCourseAppHome() {
        logger.info("Received request for course app home");
        Timer.Sample timer = Timer.start(meterRegistry);
        Span span = tracer.spanBuilder("getCourseAppHome").startSpan();
        try {
            String response = "Course App Home";
            logger.info("Returning course app home response");
            return response;
        } catch (Exception e) {
            logger.error("Error in getCourseAppHome", e);
            throw e;
        } finally {
            span.end();
            timer.stop(meterRegistry.timer("course.home.request"));
        }
    }

    @RequestMapping("/courses")
    public List<Course> getCourses() {
        logger.info("Fetching all courses");
        Timer.Sample timer = Timer.start(meterRegistry);
        Span span = tracer.spanBuilder("getCourses").startSpan();
        try {
            meterRegistry.counter("courses.accessed").increment();
            List<Course> courses = courseRepository.findAll();
            logger.info("Fetched {} courses", courses.size());
            return courses;
        } catch (Exception e) {
            logger.error("Error fetching courses", e);
            throw e;
        } finally {
            span.end();
            timer.stop(meterRegistry.timer("course.getcourses.request"));
        }
    }

    @RequestMapping("/{id}")
    public Course getSpecificCourse(@PathVariable("id") BigInteger id) {
        logger.info("Fetching course with id: {}", id);
        Timer.Sample timer = Timer.start(meterRegistry);
        Span span = tracer.spanBuilder("getSpecificCourse").startSpan();
        try {
            Course course = courseRepository.findById(id).orElse(null);
            if (course != null) {
                logger.info("Found course: {}", course.getCoursename());
            } else {
                logger.warn("Course with id {} not found", id);
            }
            return course;
        } catch (Exception e) {
            logger.error("Error fetching course with id: {}", id, e);
            throw e;
        } finally {
            span.end();
            timer.stop(meterRegistry.timer("course.getspecific.request"));
        }
    }

    @RequestMapping(method = RequestMethod.POST, value = "/courses")
    public void saveCourse(@RequestBody Course course) {
        logger.info("Saving new course: {}", course.getCoursename());
        Timer.Sample timer = Timer.start(meterRegistry);
        Span span = tracer.spanBuilder("saveCourse").startSpan();
        try {
            courseRepository.save(course);
            meterRegistry.counter("courses.created").increment();
            logger.info("Course saved successfully: {}", course.getCoursename());
        } catch (Exception e) {
            logger.error("Error saving course: {}", course.getCoursename(), e);
            throw e;
        } finally {
            span.end();
            timer.stop(meterRegistry.timer("course.save.request"));
        }
    }

    @RequestMapping(method = RequestMethod.DELETE, value = "{id}")
    public void deleteCourse(@PathVariable BigInteger id) {
        logger.info("Deleting course with id: {}", id);
        Timer.Sample timer = Timer.start(meterRegistry);
        Span span = tracer.spanBuilder("deleteCourse").startSpan();
        try {
            courseRepository.deleteById(id);
            meterRegistry.counter("courses.deleted").increment();
            logger.info("Course deleted successfully with id: {}", id);
        } catch (Exception e) {
            logger.error("Error deleting course with id: {}", id, e);
            throw e;
        } finally {
            span.end();
            timer.stop(meterRegistry.timer("course.delete.request"));
        }
    }
}
